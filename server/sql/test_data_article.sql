
-- 文章列表
-- DELETE  FROM ARTICLE;

INSERT INTO ARTICLE (`ID`,`TITLE`,`TAG`,`SUMMARY`,`CONTENT`,`CREATOR`,`CREATION_DATE`,`REVISION`)
VALUES (1009,'Redis4.0源码解析–3种线性表','标签1，标签2','这是文章的摘要',
'> 笔者博客地址： https://charpty.com/blog


为了大家看整体源码方便，我将加上了完整注释的代码传到了我的github上供大家直接下载：
> https://github.com/charpty/redis4.0-source-reading

上一章讲了SDS动态字符串，大概讲了看的方向，其实更深层次的还是要请读者自己看源码，我将源码加上了注释，这样大家看起来也更加的方便，本文讲Redis中的链表。


----------
Redis中的链表地位很高，除了Redis对外暴露的list功能用到内部的链表之外，其实内部的很多结构和功能都间接使用了链表来实现，Redis中链表的实现分为3个部分，也使用了3个C文件来描述：```ziplist.c```、```adlist.c```、```quicklist.c```，其中```quicklist.c```是在前两者的基础上实现的Redis对外暴露的列表，也就是我们经常使用的```lpush```、```linsert```、```lindex```等命令的具体实现，我们称之为```快速列表```，既然他是基于前两者（压缩列表ziplist和双向链表adlist）来实现的，那想要了解它就必须先了解前两者。

细心的读者应该注意到，我称```ziplist```为列表，称```adlist```为链表，个人理解的列表指的是内存连续或者大多数内存连续的数据结构,也就是平常所说的顺序表，而链表则用于指仅仅在逻辑上连续而在内存上不连续的列表结构。```adlist```是一个双向链表，各个节点包含了前一个节点和后一个节点指针，在```quicklist```中使用类似```adlist```的链表作为作为中控器，也就是连接一个又一个```ziplist```的链表嵌套层，```quicklist```使用双向链表存储底层数据结构```ziplist```，这样既保留了动态扩展链表的需求，又尽可能的使用了连续内存，提高了内存使用率和查询效率，大家平常所用的```LPUSH```、```LRANGE```等命令就是使用的```quicklist```。

其实```quicklist```就是```adlist```这个通用双向链表的思想加上ziplist的结合体，所以我们先来了解下通用链表```adlist```，它是Redis内部使用最多最广泛的链表，比较简单，也就是大家平常最常了解的链表，虽然实现方式没有太多的特殊点，但我们也大致讲下，方便我们后续读```quicklist```中的双向链表时做铺垫。

## 一、通用双向链表adlist
```adlist```，```a double linked list```，和这个间接普通的C源文件名字以一样，```adlist```的实现也是非常简单明了，一个普通的双向链表，我们先看其节点定义
``` c
typedef struct listNode {
    // 前一个节点
    struct listNode *prev;
    struct listNode *next;
    // 节点的具体值指针，由于为void*，所以链表中节点的值类型可以完全各不相同
    void *value;
} listNode;
```
节点的定义很简单，存储了前一个节点和后一个节点，值可以存储任意值，按理说直接使用```listNode```就直接能够构成链表结构，但是使用```adlist```定义的 ```list```结构体操作会更加的方便，我们来看下使用该结构体更加方便
``` c
  typedef struct list {
      // 链表的首个元素
      listNode *head;
      // 链表的尾部元素
      // 之所以记录尾部元素是因为可以方便的支持redis能够通过负数表示从尾部倒数索引
      listNode *tail;
      // 节点拷贝函数,在对链表进行复制时会尝试调用该函数
      // 如果没有设置该函数则仅会对链表进行浅拷贝（直接拷贝将值的地址赋给新链表节点）
      void *(*dup)(void *ptr);
      // 在释放链表节点元素内存前会尝试调用该函数,相当于节点销毁前的一个监听
      void (*free)(void *ptr);
      // 在搜索链表中节点时会调用该函数来判断两个节点是否相等
      // 如果没有设置该函数则会直接比较两个节点的内存地址
      int (*match)(void *ptr, void *key);
      // 链表当前的节点个数，即链表长度，方便统计(因为有提供给用户获取链表长度的命令llen)
      unsigned long len;
  } list;
```
虽然listNode本身可以表示链表，但是```list```结构体操作更加方便并且记录了一些关键信息，降低了查询复杂度，另外由于```list```的函数指针，使得对于链表的复制、节点释放、节点的搜索可以更加的灵活，由调用者自由定义。特别是```match```函数，由于链表的值是各异的，所以如何比较两个值是否相等是仅有链表的使用者才最清楚。

### 1.1 adlist链表插入值
创建链表的过程很简单，不再单独列出，仅是创建一个```list```结构体并设置初始值，我们看下在链表中插入值的过程
``` c
/*
   * 插入一个节点到指定节点的前面或者后面
   *
   * 参数列表
   *      1. list: 待操作的链表
   *      2. old_node: 要插入到哪一个节点的前面或者后面
   *      3. value: 要插入的值
   *      4. after: 如果为0则插入到old_value的前面，非0则插入到old_value的后面
   *
   * 返回值
   *      返回值即是链表本身，仅是为了方便链式操作
   */
  list *listInsertNode(list *list, listNode *old_node, void *value, int after) {
      listNode *node;

      // 如果不能插入新节点则返回空告诉上层调用者插入失败
      if ((node = zmalloc(sizeof(*node))) == NULL)
          return NULL;
      node->value = value;
      if (after) {
          // 插入到指定节点的后面
          node->prev = old_node;
          node->next = old_node->next;
          // 如果正好插入到了链表的尾部则将新插入的节点设置链表尾
          if (list->tail == old_node) {
              list->tail = node;
          }
      } else {
          // 插入到指定节点的前面
          node->next = old_node;
          node->prev = old_node->prev;
          // 如果正好插入到了链表头部则将新的节点设置为链表头
          if (list->head == old_node) {
              list->head = node;
          }
      }
      // 设置前后节点对应的前后指针值
      if (node->prev != NULL) {
          node->prev->next = node;
      }
      if (node->next != NULL) {
          node->next->prev = node;
      }
      list->len++;
      return list;
  }
```

### 1.2 adlist链表查询
插入链表的过程基本上能够了解到Redis这个双向链表的内部结构以及设计原理，除了这个还剩下的就是对链表的查询了，其中搜索```listSearchKey```很好的展示了链表查询的过程
``` c
/*
   * 搜索指定与key值匹配的节点, 返回第一个匹配的节点
   * 如果有链表中有匹配函数则使用匹配函数，否则直接判断key值地址与节点值地址是否相等
   *
   * 参数列表
   *      1. list: 待搜索的链表
   *      2. key: 用于搜索的key值
   *
   * 返回值
   *      与key值匹配的节点或者空
   */
  listNode *listSearchKey(list *list, void *key)
  {
      listIter iter;
      listNode *node;

      // 先重置迭代器的迭代起始位置为链表头
      listRewind(list, &iter);
      // 调用链表的迭代器逐一遍历链表元素
      while((node = listNext(&iter)) != NULL) {
          // 如果链表设置了节点匹配函数则使用否则直接比较内存地址
          if (list->match) {
              if (list->match(node->value, key)) {
                  return node;
              }
          } else {
              if (key == node->value) {
                  return node;
              }
          }
      }
      return NULL;
  }
```
Redis的通用双向链表实现比较简单，通过这两个函数基本上就对整个```adlist```有了一定的了解。

## 二、压缩列表ziplist
Redis是非常注意节约内存的，极高的内存利用率是Redis的一大特点，也是因为目前服务器的计算能力是大量富余的，所以拿计算换内存是很值得的。
```zippiest```的结构体比较复杂，先从最外层看起，结构体如下
```<total-bytes><tail-offset><len><entry>...<entry><end-mark>```
名称均是按我自己的理解命名的，也就是
```<总的内存分配大小> <末尾元素地址> <列表长度> <节点> <节点> ... <结束标记>```
这个结构仅仅是根据源码逻辑构思出来的，在Redis中没有声明任何结构体来表示这个结构，压缩列表```ziplist```的表示方法就是一个普通```char*```指针，再加上一大堆的宏操作，就构成了这个压缩列表，具体看下各个值的情况

 1.  **total-bytes**：32位整型，表示```ziplist```所用的总内存数
 2. **tail-offset**:  表示列表最有一个元素的地址，之所以有它是因为Redis的风格是大量的支持倒序索引的，有了它就很方便在尾端进行操作。
 3. **len**：列表的长度，16位整型，为了表示更大意义上的长度值甚至无限长，当它小于2^16-1时表示的是节点的个数，但是等于2^16-1时则代表该列表长度不可存储，必须要遍历列表才能得出长度
 4. **entry**：表示真正存放数据的数据项，长度是不固定的，每个entry都有自己的数据结构，用于动态表示节点长度以及编码方式
 5. **end-mark**：标记列表结束，固定值255

列表中的具体节点```entry```则显得有点复杂了，它的结构是比较典型的TLV格式，前几位来表示编码类型，然后是数据长度，接着就是数据，具体的结构如下
```<prevrawlen><len><data>```
这几个名称是在Redis源码注释中有出现的，分别代表着

 1. **prevrawlen**：前一个节点的总长度，该属性本身长度也是动态的，当前一个节点的长度小于254时，则为1个char长度，其它情况长度则为5个char，第一位char为标记位(254)，后4位char用于表示前一个节长度
 2. **len**：当前节点的真实数据的长度，和**prevrawlen**一样，该属性本身的长度也是动态的，如前文所说采用TLV形式，不同的类型对应不同的长度和数据存储方式，稍后单独讲解
 3. **data**：实际的数据，分为字符或整型两种形式存储，具体形式由**len**中设定编码决定

 对于len值编码的设定一共分为9种，我们通过宏```ZIP_DECODE_LENGTH```来了解下

 ``` c
 /*
 * 解析指定到entry节点并将编码类型，存储长度的元素的长度，列表长度的值设置到对应的变量中
 * 步骤如下
 *  1、先得到编码类型，一共9种，分别表示使用了几位字符来表示该节点的总长度
 *  2、编码小于1100 0000共有3种类型，此类型下数据(data)存储的都是字符(char)
 *      1. 00xxxxxx: 前两位作为标志位，后6位用来记录长度
 *      2. 01xxxxxx xxxxxxxx 共2位: 使用14位来记录长度，最大值位2^14 - 1
 *      3. 10xxxxxx xxxxxxxx...共5位: 使用32位来记录长度(带标记位的char整个舍弃不用)，最大值2^32 - 1
 *  3、编码大于1100 0000共规定了6种类型，长度均采用1个字符表示，每种类型数据的存储格式也各不相同
 *      4. 1100 0000: data指针存储数据格式为16字节整型
 *      5. 1101 0000: data指针存储数据格式为32字节整型
 *      6. 1110 0000: data指针存储数据格式为64字节整型
 *      7. 1111 0000: data指针存储数据格式为3字节整型
 *      8. 1111 1110: data指针存储数据格式为1字节整型
 *      9. 1111 dddd: 特殊情况，后4位表示真实数据，0～12，也就是dddd的值减去1就是真实值
 *                    之所以减1是因为较小的数字肯定是从0开始，但1111 0000又和第6点冲突
 *                    最大只到1101因为1110又和第8点冲突
 */
define ZIP_DECODE_LENGTH(ptr, encoding, lensize, len) do {                    \
    ZIP_ENTRY_ENCODING((ptr), (encoding));                                     \
    if ((encoding) < ZIP_STR_MASK) {                                           \
        if ((encoding) == ZIP_STR_06B) {                                       \
            (lensize) = 1;                                                     \
            (len) = (ptr)[0] & 0x3f;                                           \
        } else if ((encoding) == ZIP_STR_14B) {                                \
            (lensize) = 2;                                                     \
            (len) = (((ptr)[0] & 0x3f) << 8) | (ptr)[1];                       \
        } else if ((encoding) == ZIP_STR_32B) {                                \
            (lensize) = 5;                                                     \
            (len) = ((ptr)[1] << 24) |                                         \
                    ((ptr)[2] << 16) |                                         \
                    ((ptr)[3] <<  8) |                                         \
                    ((ptr)[4]);                                                \
        } else {                                                               \
            panic("Invalid string encoding 0x%02X", (encoding));               \
        }                                                                      \
    } else {                                                                   \
        (lensize) = 1;                                                         \
        (len) = zipIntSize(encoding);                                          \
    }                                                                          \
} while(0);
 ```
 根据不同的编码类型，Redis使用尽可能小的内存对其进行存储，了解了存储结构，基本上就对压缩列表```ziplist```了解了大半了，接下来我们看下它的插入操作

### 2.1 压缩列表插入值
```c
/*
 * 在压缩列表指定位置插入一个字符串值
 *
 * 参数列表
 *      1. zl: 待插入的压缩列表
 *      2. p: 要插入到哪个位置
 *      3. s: 待插入的字符串(不以NULL结尾)的起始地址
 *      4. slen: 待插入的字符串的长度，由于不是标准的C字符串，所以需要指定长度
 *
 * 返回值
 *      压缩列表地址
 */
unsigned char *__ziplistInsert(unsigned char *zl, unsigned char *p, unsigned char *s, unsigned int slen) {
    // 先取出当前压缩列表总内存分配长度
    size_t curlen = intrev32ifbe(ZIPLIST_BYTES(zl)), reqlen;
    unsigned int prevlensize, prevlen = 0;
    size_t offset;
    int nextdiff = 0;
    unsigned char encoding = 0;
    // 这个初始化值只是为了防止编译器警告
    long long value = 123456789;
    zlentry tail;

    // 因为每个节点都会记录上一个节点数据占用的内存长度(方便倒序索引)，所以先查出该值
    // 如果待插入的位置是压缩列表的尾部, 则相当于尾部追加
    if (p[0] != ZIP_END) {
        // 如果不是插入尾部则根据p正常获取前一个节点的长度
        ZIP_DECODE_PREVLEN(p, prevlensize, prevlen);
    } else {
        // 如果是尾部追加则先获取列表中最后一个节点的地址(注意最后一个节点并不一定是列表结束)
        unsigned char *ptail = ZIPLIST_ENTRY_TAIL(zl);
        // 如果最后一个节点也是空的(ptail[0]==列表结束标记)则代表整个压缩列表都还是空列表
        // 如果不是空列表则正常取出最后一个节点的长度
        if (ptail[0] != ZIP_END) {
            // 取出尾部节点所占内存字符长度
            prevlen = zipRawEntryLength(ptail);
        }
    }

    // 如果可以转换为整型存储则使用整型存储
    if (zipTryEncoding(s,slen,&value,&encoding)) {
        // 计算整型所占长度
        // 1位: -128~127，2位: -32768~3276...
        reqlen = zipIntSize(encoding);
    } else {
        // 如果不能转换为整型存储则直接使用字符串(char)方式存储
        reqlen = slen;
    }
    // 除了存储数据(V)，一个节点还还需要存储编码类型(T)和节点长度(L)以及前一个节点的长度
    // 计算出存储上一个节点长度的值所需要的内存大小
    reqlen += zipStorePrevEntryLength(NULL,prevlen);
    // 计算处需要存储自己的编码类型所需的内存大小
    reqlen += zipStoreEntryEncoding(NULL,encoding,slen);

    // 计算出存储该节点的长度所需的内存大小并尝试赋值给该节点的下一个节点(每个都节点存储上一个节点的长度)
    int forcelarge = 0;
    // 如果插入的节点不是列表尾的话，那该节点的下一个节点应该存储该节点的长度
    // 计算出下一个节点之前已经分配的用于存储上一个节点长度的内存和目前存储实际所需内存的差距
    nextdiff = (p[0] != ZIP_END) ? zipPrevLenByteDiff(p,reqlen) : 0;
    // 其实存储长度值仅有两种可能，小于254则使用一个char存储，其它则使用5个char存储
    if (nextdiff == -4 && reqlen < 4) {
        // 如果所需内存减少了(之前一个节点长度比当前节点长)
        // 但是当前节点又已经存储为较小的整数的情况下(共两种编码)则不进行缩小了
        nextdiff = 0;
        forcelarge = 1;
    }

    offset = p-zl;
    // 根据新加入的元素所需扩展的内存重新申请内存
    zl = ziplistResize(zl,curlen+reqlen+nextdiff);
    // 重新申请之后原来的p有可能失效(因为整块列表地址都换了)，所以根据原先偏移量重新计算出地址
    p = zl+offset;

    // 接下来开始挪动p两端的位置并把新的节点插入
    if (p[0] != ZIP_END) {
        // 把p位置之后的元素都往后移动reqlen个位置，空出reqlen长度的内存给新节点使用
        memmove(p+reqlen,p-nextdiff,curlen-offset-1+nextdiff);
        // 将新节点的长度设置到后一个节点之中
        if (forcelarge)
            // 如果满足我们前面计算nextdiff的所设定的不缩小条件则强行保留5个char来存储新节点的长度
            zipStorePrevEntryLengthLarge(p+reqlen,reqlen);
        else
            zipStorePrevEntryLength(p+reqlen,reqlen);

        // 设置zl头部中尾部元素偏移量
        ZIPLIST_TAIL_OFFSET(zl) =
            intrev32ifbe(intrev32ifbe(ZIPLIST_TAIL_OFFSET(zl))+reqlen);

        // 节约变量，直接使用tail作为节点
        zipEntry(p+reqlen, &tail);
        if (p[reqlen+tail.headersize+tail.len] != ZIP_END) {
            ZIPLIST_TAIL_OFFSET(zl) =
                intrev32ifbe(intrev32ifbe(ZIPLIST_TAIL_OFFSET(zl))+nextdiff);
        }
    } else {
        // 如果本身要插到尾部则元素偏移位置就是头部到插入位置p的
        ZIPLIST_TAIL_OFFSET(zl) = intrev32ifbe(p-zl);
    }

    // 如果下个节点的长度有所变化(因为存储当前节点的长度所占内存变化了)
    // 那意味着因为下个节点长度变化，下下个节点存储下个节点长度的内存也发生了变化又导致下下个节点的长度变化
    // 这改变是个蝴蝶效应，所以需要逐一遍历修改
    if (nextdiff != 0) {
        offset = p-zl;
        zl = __ziplistCascadeUpdate(zl,p+reqlen);
        p = zl+offset;
    }

    /* Write the entry */
    // 将前一个节点的长度存入该节点首部
    p += zipStorePrevEntryLength(p,prevlen);
    // 存储该节点数据编码方式和长度
    p += zipStoreEntryEncoding(p,encoding,slen);
    if (ZIP_IS_STR(encoding)) {
        // 如果是字符编码则直接拷贝
        memcpy(p,s,slen);
    } else {
        // 整型编码则存储对应整型
        zipSaveInteger(p,value,encoding);
    }
    // 将列表的长度加1
    ZIPLIST_INCR_LENGTH(zl,1);
    return zl;
}
```

虽然代码中已经有很多的注释，但还是简单解释一下，函数的功能是在指定的位置p插入一个新的entry，起始位置为p，数据的地址指针是s，原来位于p位置的数据项以及后面的所有数据项，需要统一向后偏移。该函数可以将数据插入到列表中的某个节点后，也可以插入到列表尾部。

1. 首先计算出待插入位置的前一个entry的长度prevlen，稍后要将这个值存入到新节点的**prevrawlen**属性中
2. 计算新的entry总共需要内存数，一个entry包含3个部分，所以这个内存数是这3部分的总和，当然也可能因为值小于13而变成没有data部分
3. 压缩列表有一个比较麻烦的地方就是每个节点都存储了前一个节点的长度，而且存储内存本身也是动态的，那么当新节点插入，它的下一个节点则要存储它的长度，这有可能引起下一个节点发生长度变化，因为可能原先下一个节点的**prevrawlen**仅需一个字符存储，结果新的节点的长度大于254了，那就需要5个字符来存储了，此时下一个节点的长度发生了变化，更可怕的是，由于下一个节点长度发生了变化，下下一个节点也面临着同样的问题，这就像是蝴蝶效应，一个小小的改动却带来惊天动地的变化， Redis称之为瀑布式改变，当然Redis也做了些许优化，当节点尝试变短时会根据某些条件仅可能避免这种大量改动的发生
4. 既然长度发生了变化则要申请新的内存空间并将原来的值拷贝过去，之后就是生成新的节点，并将其插入到列表中，设置新节点的各个属性值，当然还有对列表本身的长度和总内存等进行设置

### 2.2 压缩列表获取值
```ziplist```获取值的方法基本上就是插入的逆序，根据编码类型和值长度来算出具体值的位置并转换为相应结果。
``` C
/*
 * 获取p节点的实际数据的值并设置到sstr或sval中，如何设置取决于节点的编码类型
 *
 * 参数列表
 *      1. p: 指定的节点，该节点为列表尾或者指针无效时则告诉调用者获取节点值失败
 *      2. sstr: 出参字符串，如果该节点是以字符串形式编码的话则会设置该出参
 *      3. slen: 出参字符串长度
 *      4. sval: 出参整型，如果该节点是以整型编码(任何一种整型编码)则会设置该出参为节点实际数据值
 *
 * 返回值
 *      返回0代表指定的节点无效，返回1则代表节点有效并成功获取到其实际数据值
 */
unsigned int ziplistGet(unsigned char *p, unsigned char **sstr, unsigned int *slen, long long *sval) {
    zlentry entry;
    if (p == NULL || p[0] == ZIP_END) return 0;
    // 调用者是以sstr有没有被设置值来判断该节点是以整型编码还是字符串编码的
    // 为了防止出现歧义所以强制将sstr先指向空
    if (sstr) *sstr = NULL;

    // 将节点p的属性设置到工具结构体中，这样处理起来方便的多
    zipEntry(p, &entry);
    if (ZIP_IS_STR(entry.encoding)) {
        // 如果是以字符串编码则设置字符串出参
        if (sstr) {
            *slen = entry.len;
            *sstr = p+entry.headersize;
        }
    } else {
        if (sval) {
            // 取出实际的整型数据
            *sval = zipLoadInteger(p+entry.headersize,entry.encoding);
        }
    }
    return 1;
}
```
```ziplist```没有明确的定义，大多数操作都是通过宏定义的，获取值也不例外
``` C
/*
 * 设置压缩列表节点的属性值
 *
 * 参数列表
 *      1.p: 新节点内存的起始地址
 *      2.e: 一个节点结构体的指针
 */
void zipEntry(unsigned char *p, zlentry *e) {
    // 首先设置该节点第一个元素(存储前一个节点的长度)
    ZIP_DECODE_PREVLEN(p, e->prevrawlensize, e->prevrawlen);
    // 设置该节点的数据编码类型和数据长度
    ZIP_DECODE_LENGTH(p + e->prevrawlensize, e->encoding, e->lensize, e->len);
    // 记录节点头部总长度
    e->headersize = e->prevrawlensize + e->lensize;
    e->p = p;
}
```

## 三、快速链表quicklist
Redis暴露给用户使用的list数据类型（即```LPUSH```、```LRANGE```等系列命令），实现所用的内部数据结构就是```quicklist```，```quicklist```的实现是一个封装了```ziplist```的双向链表，既然和```adlist```一样就是个双向链表，那我们在已经了解```adlist```的情况下学习```quicklist```就会快很多，但是```quicklist```要比```adlist```复杂的多，原因在于额外的压缩和对```ziplist```的封装，首先我们来看下它是如何```ziplist```的，每一个```ziplist```都会被封装为一个```quicklistNode```，它的结构如下
``` C
/*
 * 快速列表的具体节点
 */
typedef struct quicklistNode {
    // 前一个节点
    struct quicklistNode *prev;
    // 后一个节点
    struct quicklistNode *next;
    // ziplist首部指针，各节点的实际数据项存储在ziplist中(连续内存空间的压缩列表)
    unsigned char *zl;
    // ziplist占用的总内存大小，不论压缩与否都是存储实际的总内存大小
    unsigned int sz;
    // ziplist的数据项的个数
    unsigned int count : 16;
    // 该节点是否被压缩过了，1代表没压缩，2代表使用LZF算法压缩过了
    // 可能以后会有别的压缩算法，目前则只有这一种压缩算法
    unsigned int encoding : 2;
    // 该节点使用何种方式来存储数据，1代表没存储数据，2代表使用ziplist存储数据
    // 这个节点目前看来都是2，即使用ziplist来存储数据，后续可能会有别的方式
    unsigned int container : 2;
    // 这个节点是否需要重新压缩？
    // 某些情况下需要临时解压下这个节点，有这个标记则会找机会再重新进行压缩
    unsigned int recompress : 1;
    // 节点数据不能压缩？
    unsigned int attempted_compress : 1;
    // 只是一个int正好剩下的内存，目前还没使用上，可以认为是扩展字段
    unsigned int extra : 10;
} quicklistNode;
```
可以清楚到看到快速链表的节点（```quicklistNode```）主要是对```ziplist```封装，复杂的地方在于控制各个```ziplist```的长度和压缩情况，从结构设计上可以看到Redis可能还打算使用别的结构代替```ziplist```作为存储实际数据的节点，但目前在4.0版本中仅有```ziplist```这一种，压缩算法也只有```lzf```。

### 3.1 创建快速链表
当用户执行```LPUSH```命令时，如果指定的列表名称在Redis不存在则会创建一个新的快速链表，代码调用路径大致如下
```
server.c 事件循环 --> 调用module API --> module.c moduleCreateEmptyKey() --> object.c createQuicklistObject() --> quicklist.c quicklistCreate()
```
主要判断逻辑在```module.c```中
``` C
/*
 * LPUSH命令的实现
 * 将元素加入到一个Redis List集合中(快速链表quicklist)，如果该key的List不存在则会创建一个List
 * 当key存在确不是List类型时则会抛出类型不符合错误
 *
 */
int RM_ListPush(RedisModuleKey *key, int where, RedisModuleString *ele) {
    // 如果对应的key是只读的则会返回键值不可写错误
    if (!(key->mode & REDISMODULE_WRITE)) return REDISMODULE_ERR;
    // 如果存在key但是类型不是List则会返回类型不符合错误
    if (key->value && key->value->type != OBJ_LIST) return REDISMODULE_ERR;
    // 如果指定key不存在则创建一个quicklist类型的对象
    if (key->value == NULL) moduleCreateEmptyKey(key,REDISMODULE_KEYTYPE_LIST);
    // 将具体的值存入List值
    listTypePush(key->value, ele,
        (where == REDISMODULE_LIST_HEAD) ? QUICKLIST_HEAD : QUICKLIST_TAIL);
    return REDISMODULE_OK;
}

```
之后就是调用quicklist.c中的方法来创建一个快速链表
``` C
/*
 * 创建一个快速链表
 * 当使用LPUSH创建List时会调用该函数
 *
 * 返回值
 *      新的快速链表的指针
 */
quicklist *quicklistCreate(void) {
    struct quicklist *quicklist;

    quicklist = zmalloc(sizeof(*quicklist));
    quicklist->head = quicklist->tail = NULL;
    quicklist->len = 0;
    quicklist->count = 0;
    quicklist->compress = 0;
    // -2代表ziplist的大小不超过8kb
    quicklist->fill = -2;
    return quicklist;
}
```

### 3.2 快速链表插入值
插入值的方式有很多种，比如从插入到头部、插入到尾部、插入到某个节点前面、从其他ziplist导入等等，但原理都差不多，我们这里仅看插入到头部即可
``` C
/*
   * 在链表的首部添加一个节点
   *
   * 参数列表
   *      1. quicklist: 待操作的快速链表
   *      2. value: 待插入的值
   *      3. sz: 值的内存长度
   *
   * 返回值
   *      返回1代表创建了一个新的节点，返回0代表使用了既有的节点
   */
  int quicklistPushHead(quicklist *quicklist, void *value, size_t sz) {
      quicklistNode *orig_head = quicklist->head;
      // likely是条件大概率为真时的语法优化写法
      // 首先需要判断当前快速链表节点是否能够再添加值
      if (likely(
              _quicklistNodeAllowInsert(quicklist->head, quicklist->fill, sz))) {
          // 能的话则将值插入到当前节点对应的ziplist中即可
          quicklist->head->zl =
              ziplistPush(quicklist->head->zl, value, sz, ZIPLIST_HEAD);
          quicklistNodeUpdateSz(quicklist->head);
      } else {
          // 不能则创建一个新的快速链表节点并将值插入
          quicklistNode *node = quicklistCreateNode();
          node->zl = ziplistPush(ziplistNew(), value, sz, ZIPLIST_HEAD);

          quicklistNodeUpdateSz(node);
          _quicklistInsertNodeBefore(quicklist, quicklist->head, node);
      }
      quicklist->count++;
      quicklist->head->count++;
      return (orig_head != quicklist->head);
  }
```

### 3.3 从快速链表中获取值
获取值最麻烦的地方在于需要解压```ziplist```，目前Redis使用的是```lzf```压缩算法（也可以说是个编码算法），要注意的是```quicklist```中的获取值都是指获取真实的数据项的值，也就是存储在各个```ziplist```中的数据项，而不是指```quicklistNode```。
``` C
/*
 * 获取指定位置的节点
 *
 * 参数列表
 *      1. quicklist: 待操作的链表
 *      2. idx: 节点位置序号，大于0表示从链表头开始索引，小于代表从链表尾部开始索引
 *              注意这个序号是所有ziplist的所有节点的序号，不是quicklist节点的序号
 *      3. entry: 出参，如果找到节点则将节点的属性设置到该entry中
 *
 * 返回值
 *      返回1代表成功找到指定位置节点，否则返回0
 */
int quicklistIndex(const quicklist *quicklist, const long long idx,
                   quicklistEntry *entry) {
    quicklistNode *n;
    unsigned long long accum = 0;
    unsigned long long index;
    // 小于0从后往前搜索
    int forward = idx < 0 ? 0 : 1; /* < 0 -> reverse, 0+ -> forward */

    // 这里会对entry设置一些初始值，所以必须通过该函数返回值判断获取成功失败
    // 而不能通过entry是否设置来判断
    initEntry(entry);
    entry->quicklist = quicklist;

    if (!forward) {
        // 从尾部开始遍历-1代表第1个节点(位置0),-2代表第二个节点(位置1)
        index = (-idx) - 1;
        n = quicklist->tail;
    } else {
        index = idx;
        n = quicklist->head;
    }

    // 如果指定位置超出了链表本身长度
    if (index >= quicklist->count)
        return 0;

    // 编译器和linux系统的一种优化语法糖
    // 当条件为真的可能性很大时使用该写法可以提高执行效率
    while (likely(n)) {
        // 这个循环只能算出想要的节点在哪个ziplist中，后续再从ziplist取出真正节点
        if ((accum + n->count) > index) {
            break;
        } else {
            D("Skipping over (%p) %u at accum %lld", (void *)n, n->count,
              accum);
            // 每个快速列表的节点都记录了它附带的ziplist中的节点个数
            accum += n->count;
            n = forward ? n->next : n->prev;
        }
    }
    // 如果没有找到指定节点则返回失败
    if (!n)
        return 0;
    // 调试日志
    D("Found node: %p at accum %llu, idx %llu, sub+ %llu, sub- %llu", (void *)n,
      accum, index, index - accum, (-index) - 1 + accum);
    entry->node = n;
    // 设置在当前ziplist中还要偏移多少个位置才是真正的数据节点
    if (forward) {
        entry->offset = index - accum;
    } else {
        entry->offset = (-index) - 1 + accum;
    }

    // 解压当前节点的ziplist，由于是将该节点给调用者使用，所以解压之后不再重新压缩
    // 由调用者根据重压缩标志决定是否需要再压缩
    quicklistDecompressNodeForUse(entry->node);
    // 获取实际的数据节点首部指针
    entry->zi = ziplistIndex(entry->node->zl, entry->offset);
    // 到此已找到数据节点，现把数据节点中的实际数据取出并根据编码类型设置不同属性
    // 值得注意的是调用者通过entry的value属性是否有值来判断实际数据是否是字符串编码
    ziplistGet(entry->zi, &entry->value, &entry->sz, &entry->longval);
    return 1;
}
```
我们看到最终的出参是```quicklistEntry```，这是一个工具型结构体，主要用于中间过渡和方便程序调用，在```ziplist```的实现中也有类似的工具型结构体，```quicklistEntry```的定义如下
``` C
// 快速列表节点表示的工具型结构体
// 和ziplist的zlenty类似，一切为了操作方便
typedef struct quicklistEntry {
    // 快速链表
    const quicklist *quicklist;
    // 对应的节点
    quicklistNode *node;
    // 在ziplist中的实际的数据节点的首部指针
    unsigned char *zi;
    // 如果实际数据是字符串编码类型则值设置在该属性中
    unsigned char *value;
    // 如果实际数据是整型编码类型则值设置在该属性中
    long long longval;
    // 不同使用场景下表示意义稍有不同
    // 获取指定节点实际数据值时表示字符串编码情况下字符串的长度
    unsigned int sz;
    int offset;
} quicklistEntry;
```
我们经常使用的```LRANGE```命令则是通过链表的迭代器来实现的，其实```adlist```和```ziplist```都是有迭代器的，通过迭代器可以从指定位置开始逐个遍历链表中的值，非常方便且安全。
```LRANGE```的主要调用流程如下
```
server.c 事件循环 --> 命令表 lrangeCommand命令 --> t_list.c lrangeCommand() --> quicklist.c quicklistGetIteratorAtIdx() --> quicklist.c quicklistNext()
```
初始化迭代器的过程很简单
``` C
/*
 * 创建一个从链表指定位置开始的迭代器
 *
 * 参数列表
 *      1. quicklist: 待操作的链表
 *      2. direction: 迭代方向
 *      3. idx: 从哪个位置开始
 *
 * 返回值
 *      链表迭代器，是链表迭代函数的入参
 */
quicklistIter *quicklistGetIteratorAtIdx(const quicklist *quicklist,
                                         const int direction,
                                         const long long idx) {
    quicklistEntry entry;

    if (quicklistIndex(quicklist, idx, &entry)) {
        quicklistIter *base = quicklistGetIterator(quicklist, direction);
        base->zi = NULL;
        base->current = entry.node;
        base->offset = entry.offset;
        return base;
    } else {
        return NULL;
    }
}
```
获取到一个迭代器的指针之后，就可以将其作为参数传递给```quicklistNext```方法逐个遍历值
``` C
/*
 * 获取快速链表的下一个节点
 *
 * 参数列表
 *      1. iter: 链表迭代器，可以通过quicklistGetIterator()函数获得
 *      2. entry: 出参，如果获取到下一个节点则设置属性到该工具型结构体中
 *
 * 返回值
 *
 */
int quicklistNext(quicklistIter *iter, quicklistEntry *entry) {
    // 重置出参entry的属性值
    initEntry(entry);

    // 如果迭代器无效则返回
    if (!iter) {
        D("Returning because no iter!");
        return 0;
    }

    // 当前遍历的链表是肯定不变的
    entry->quicklist = iter->quicklist;
    // 当前遍历的快速链表节点也大概率不会改变
    entry->node = iter->current;

    // 当前已遍历完毕
    if (!iter->current) {
        D("Returning because current node is NULL")
        return 0;
    }

    unsigned char *(*nextFn)(unsigned char *, unsigned char *) = NULL;
    int offset_update = 0;

    if (!iter->zi) {
        // 如果没有还未获取到ziplist的具体数据节点则使用偏移址获取
        // 发生在两个快速链表节点切换时，也就是换到下一个ziplist时
        /* If !zi, use current index. */
        // 首先需要将新的ziplist解压
        quicklistDecompressNodeForUse(iter->current);
        // 之后获取到到指定真实数据节点
        iter->zi = ziplistIndex(iter->current->zl, iter->offset);
    } else {
        /* else, use existing iterator offset and get prev/next as necessary. */
        // 如果没有切换ziplist那就在现有的ziplist中通过ziplist节点特性寻找下一个数据节点
        // ziplist中的节点记录了上一个节点的长度和当前节点的长度所以既可以往前遍历也可以往后遍历
        if (iter->direction == AL_START_HEAD) {
            nextFn = ziplistNext;
            offset_update = 1;
        } else if (iter->direction == AL_START_TAIL) {
            nextFn = ziplistPrev;
            offset_update = -1;
        }
        iter->zi = nextFn(iter->current->zl, iter->zi);
        iter->offset += offset_update;
    }

    entry->zi = iter->zi;
    entry->offset = iter->offset;

    if (iter->zi) {
        /* Populate value from existing ziplist position */
        // 如果当前ziplist有效(还有数据)则直接取当前ziplist下一个值即可
        ziplistGet(entry->zi, &entry->value, &entry->sz, &entry->longval);
        return 1;
    } else {
        /* We ran out of ziplist entries.
         * Pick next node, update offset, then re-run retrieval. */
        // 当前ziplist无效(其数据节点已遍历完)则获取下一个quicklistNode中的ziplist
        quicklistCompress(iter->quicklist, iter->current);
        if (iter->direction == AL_START_HEAD) {
            // 从前往后遍历
            D("Jumping to start of next node");
            // 获取下一个quicklistNode并将迭代器指向的当前ziplist置空
            iter->current = iter->current->next;
            iter->offset = 0;
        } else if (iter->direction == AL_START_TAIL) {
            // 从后往前遍历
            D("Jumping to end of previous node");
            iter->current = iter->current->prev;
            iter->offset = -1;
        }
        // 将迭代器当前有效的ziplist置空以便递归调用时知道是要重新从quicklistNode中取出ziplist
        iter->zi = NULL;
        return quicklistNext(iter, entry);
    }
}
```

快速链表获取值的方式还有从尾部弹出、从首部弹出等，其核心思想都是先找到指定的```ziplist```并将其中的真实数据解压出来返回。

### 小结
双向链表很好理解，压缩列表则比较繁琐，希望对大家读Redis4.0源码有所帮助，我觉得重要的还是自己去看和调试，当然如果源码中带有中文注释看着肯定事半功倍，所以大家可以**clone**文章顶部的仓库，随时更新。

线性表list是Redis中非常重要的数据结构，不论是Reids内部还是暴露给客户的数据结构中都有使用到，和Redis的动态字符串一样，这几种list可以单独使用，将其源文件拷贝以及依赖的几个源文件拷贝出来就可以非常的方便的再自己的项目中直接使用（使用时记得查看开源协议规范）。','蔡博','2017-08-25 22:39:02',0);

INSERT INTO ARTICLE (`ID`,`TITLE`,`TAG`,`SUMMARY`,`CONTENT`,`CREATOR`,`CREATION_DATE`,`REVISION`)
VALUES (1010,'Redis4.0源码解析–动态字符串SDS','标签1，标签2','这是文章的摘要',
'
Redis官方在2016年12月发布了4.0-rc1版本，从此揭开了4.0版本的序幕，但到目前为止（2017年6月）还没有正式发布4.0版本提供给生产环境使用，笔者在2.8时代开始接触Redis，在做的几个项目中也都使用它作为缓存和数据交换的渠道，想着前辈们把3.0版本都源码解析的都差不多了，网上4.0版本解析却很少，所以和大家共同分享下Redis源码阅读的经历。
本文所指的新特性对比的是 https://github.com/antirez/redis 仓库中3.0分支和4.0分支的差异。

> 为了大家看整体源码方便，我将加上了完整注释的代码传到了我的github上供大家直接下载：
> https://github.com/charpty/redis4.0-source-reading


## SDS动态字符串
和其它分析Redis之前版本一样，先来看最基本字符串都处理，SDS是Redis自定义都动态字符串，全称为```Simple Dynamic Strings```，和之前版本一样SDS还是由两部分组成，结合代码我称之为头部（sdshdr结构体）和sds（实际字符串指针），组成如下：
+--------------------------------------------------------
| 头部 | 标准的C字符串 | 剩余的未分配空间
+--------------------------------------------------------

原理比较简单，头部中记录了已使用的长度和总的分配长度（之前版本是记录的剩余长度），这样想追加字符串时不需要像单纯C语言那样重新开辟一块空间然后将原字符串和追加内容一起拷贝过去，而是直接将其添加到SDS未分配的空间中，当然，遇到剩余未分配空间不足的情况则需要进行扩容。

 - ```sds.c```和```sds.h```文件为Redis的"动态字符串（SDS）"数据结构的实现
 - SDS分为两部分，一部分称为头部(```sdshdr```结构体)
 - 另一部分则是实际的字符串（地址紧跟```sdshdr```结构体后,代码中称为```sds```）
 - 小写的类型别名```sds```则是指实际的字符串，也就是SDS的第二部分


### SDS特性
SDS最大的一个好处就是它对C标准字符串的兼容是非常好的，它定义了一个类型别名
```
// 类型别名，指向sdshdr结构体中的buf属性，也就是实际的字符串的指针
// 注意将其与大写SDS区分
// SDS泛指的Redis设计的动态字符串结构(结构体sdshdr + 实际字符串sds)
typedef char *sds;
```
当进行创建字符串、追加字符串、拷贝字符串等等几乎所有操作时都是返回```sds```，大家也注意到其实sds也就是```char*```类型，加之SDS总是在字符串尾部添加```''\0''```所以它就是一个标准的C字符串，这样在使用时非常方便，不像其它动态字符串结构体一样，每次想获取实际的字符串都得```p->buf```，当然这么涉及带来了方便也带来了危险，由于是直接将实际的字符串返回给调用者使用，所以当程序在多处地方使用同一个引用时很容易出现内存泄漏问题。

除了兼容C字符串，SDS还具有动态扩容特性和二进制安全（操作都是memcpy）的特点，对于4.0版本的，我觉得很大的改进是SDS的空间利用率有显著的提高，但计算效率有所下降（为了区分具体使用哪种头部结构体不得不每次都计算或判断）

**Redis的作者为SDS单独开辟了一个仓库**，他希望将SDS独立于Redis，让SDS也可以被其它项目单独使用（我在某次向Redis提交PR的时候有个好心的哥们告诉我SDS的修改需要向新仓库提交）
独立的SDS仓库：https://github.com/antirez/sds

### 头部结构体
在之前的版本中，仅用一个结构体表示头部
```
struct sdshdr {
    // buf 中已使用的长度
    int len;
    // buf 中剩余可使用的长度
    int free;
    // 柔性数组，实际字符串地址
    char buf[];
};
```
在4.0版本少有变化，free改为了alloc（总分配长度），并添加了flags标记具体使用了哪一种结构体，这是因为4.0版本针对不同的字符串长度使用了不同的结构体，比如长度小于32的字符串，则会使用sdshdr5结构体
```
struct __attribute__ ((__packed__)) sdshdr5 {
	// flags既是标记了头部类型，同时也记录了字符串的长度
	// 共8位，flags用前5位记录字符串长度（小于32=1<<5），后3位作为标志
    unsigned char flags;
    char buf[];
};
```
在字符串本身较短的情况下，SDS的内存分配是非常节约的，巧妙的利用一个标志位来记录长度，减少头部所占内存。
再比如字符串长度大于32且小于256时则判定为```SDS_TYPE_8```类型
```
// __attribute__是为了增强编译器检查
// __packed__则是告诉编译器则可能少的分配内存
struct __attribute__ ((__packed__)) sdshdr8 {
    // 字符串的长度，即已经使用的buf长度
    uint8_t len;
    // 为buf分配的总长度，之前版本记录的是free(还剩下多少长度)
    uint8_t alloc;
    // 新增属性，记录该结构体的实际类型
    unsigned char flags;
    // 柔性数组，为结构体分配内存的时候顺带分配，作为字符串的实际存储内存
    // 由于buf不占内存，所以buf的地址就是结构体尾部的地址，也是实际字符串开始的地址
    char buf[];
};
```
新版本一共定义了5种类型，会根据不同的字符串长度来分配
```
/*
 * 根据字符串的长度确定要使用的实际sdshdr结构体的类型
 *
 * 参数列表
 *      1. string_size: 用于初始化的字符串的长度
 *
 * 返回值
 *      要使用的sdshdr类型，一共5种，仅SDS_TYPE_5比较特殊(sdshdr5是非常节约内存的一个结构体)
 *      其他类型都相同，记录了使用长度和总分配长度
 *      所有结构体都有记录具体结构体类型的flags属性和末尾柔性数组（用于动态分配实际字符串存储空间）
 */
static inline char sdsReqType(size_t string_size) {
    if (string_size < 1<<5)
        return SDS_TYPE_5;
    if (string_size < 1<<8)
        return SDS_TYPE_8;
    if (string_size < 1<<16)
        return SDS_TYPE_16;
#if (LONG_MAX == LLONG_MAX)
    if (string_size < 1ll<<32)
        return SDS_TYPE_32;
#endif
    return SDS_TYPE_64;
}
```
SDS的结构本质上和之前没有什么变化，只是添加了不同长度字符串不同头部结构体的特性，接下来我们通过SDS字符串最主要的几个操作来具体看下源码

## 创建SDS
创建一个SDS并返回实际的字符串指针sds一共有4种方法
```
// 实际上内部都调用这个函数
sds sdsnewlen(const void *init, size_t initlen);
sds sdsnew(const char *init);
sds sdsempty(void);
sds sdsdup(const sds s);
```
由于其它3个函数实际上都调用```sdsnewlen```这个函数，我们仅对该函数分析即可了解整个创建过程。
```
/*
 * 截取给定字符串指定长度作为初始化值来创建一个SDS(sdshdr结构体+实际字符串)动态字符串
 *
 * 参数列表
 *      1. init: 用于初始化sds的普通字符串, 将根据initlen截取其中一部分作为初始化值
 *      2. initlen: 指定要截取多少长度的init字符串作为初始化值
 *
 * 返回值
 *      SDS中的实际字符串的指针
 */
sds sdsnewlen(const void *init, size_t initlen) {
    // 为何什么一个void*而不是struct shshdr *sh呢
    // 因为新版本为了进一步提升性能，不同的长度的字符串将使用不同的结构体
    // SDS_HDR_VAR这个宏用于具体创建结构体，变量名必须为sh,宏里已经写死
    void *sh;
    // sds是类型别名，其实就是sdshdr中的buf属性的指针
    sds s;
    // 根据不同的长度决定使用不同的结构体
    // 在sds.h中共声明了5种sdshdr结构体
    char type = sdsReqType(initlen);
    // 这是个经验写法，当想构造空串时大多数情况都是为了放入超过32长度的字符串
    if (type == SDS_TYPE_5 && initlen == 0) type = SDS_TYPE_8;
    int hdrlen = sdsHdrSize(type);
    // 新版本中添加到sdshdr结构体中的新变量,为了标记到底使用了哪种结构体
    unsigned char *fp; /* flags pointer. */

    // +1是为了放字符串结尾''\0''
    sh = s_malloc(hdrlen+initlen+1);
    if (!init)
        memset(sh, 0, hdrlen+initlen+1);
    if (sh == NULL) return NULL;
    s = (char*)sh+hdrlen;
    // s是shshdr的末尾柔性数组，所以-1就得到结构体中的flags属性的地址
    fp = ((unsigned char*)s)-1;
    switch(type) {
        case SDS_TYPE_5: {
            // 标志位仅为后3位，左移3位相当于标志位置0
            // 且因为长度小于32所以不会丢失字符串长度真实数值
            // 此时字符串实际长度和总分配长度都不需要记录，fp >> 3就是结果
            *fp = type | (initlen << SDS_TYPE_BITS);
            break;
        }
        // 其他情况则按照长度分配不同的结构体并设置属性
        case SDS_TYPE_8: {
            SDS_HDR_VAR(8,s);
            sh->len = initlen;
            sh->alloc = initlen;
            *fp = type;
            break;
        }
        case SDS_TYPE_16: {
            ...省略
        }
        case SDS_TYPE_32: {
            ...省略
        }
        case SDS_TYPE_64: {
            ...省略
        }
    }
    // 将初始化字符串拷贝到sdshdr结构体的末尾
    // 这体现了柔性数组或者说动态数组确实分配方便且使用简洁
    if (initlen && init)
        memcpy(s, init, initlen);
    s[initlen] = ''\0'';
    // 这里返回的不是sdshrd结构体而是返回结构体中的buf，也就是真正的字符串
    // 这么做主要因为Redis代码中大多数用到的都是字符串而不是sdshdr结构体,直接用sds(char*)会比用结构体方便的多
    // 在新版本中由于采用多种sdshdr也没办法返回sdshdr结构体（老版本也是返回sds，这里仅做说明）
    return s;
}
```

## 追加字符串
和创建字符串一样，追加字符串最终也是调用同一个函数sdscatlen()进行追加
```
/*
 * 截取指定字符串的指定长度追加到原有字符串中
 *
 * 参数列表
 *      1. s: 原有字符串，空间不够则会对该字符串所在sdshdr结构体进行扩容
 *      2. t: 要追加到原有字符串后的值
 *      3. len: 要截取的待拷贝的值的长度
 *
 * 返回值
 *      新的sds字符串指针或原先的sds字符串指针
 */
sds sdscatlen(sds s, const void *t, size_t len) {
    // 先算出当前字符串所在sdshdr结构体中已使用的字符串长度
    // 这里可以使用标准的strlen计算因为确实添加''\0''到字符串尾部但这样做只是为了兼容字符串使用
    // 所以这里取结构体中记录的长度值而不是去依赖兼容写法
    size_t curlen = sdslen(s);
	// 根据新长度进行扩容或者保持不变
    s = sdsMakeRoomFor(s,len);
    if (s == NULL) return NULL;
    // 直接进行内存拷贝而不是字符串拷贝保证了二进制兼容
    memcpy(s+curlen, t, len);
    // 设置新长度
    sdssetlen(s, curlen+len);
    s[curlen+len] = ''\0'';
    return s;
}
```
追加函数本身并不是关键，我们关注的是它如何进行扩容，扩容都在sdsMakeRoomFor()函数中完成
```
/*
 * 在必要情况下对SDS进行扩容
 *
 * 参数列表
 *      1. s: 待扩容对SDS对字符串指针
 *      2. addlen: 需要新加入字符串的长度
 *
 * 返回值
 *      返回扩容后新的sds，如果没扩容则和入参sds地址相同
 */
sds sdsMakeRoomFor(sds s, size_t addlen) {
    void *sh, *newsh;
    // 首先计算出原SDS还剩多少可分配空间
    size_t avail = sdsavail(s);
    size_t len, newlen;
    char type, oldtype = s[-1] & SDS_TYPE_MASK;
    int hdrlen;

    /* Return ASAP if there is enough space left. */
    // 已经够用的情况下直接返回
    if (avail >= addlen) return s;

    len = sdslen(s);
    // 用sds（指向结构体尾部，字符串首部）减去结构体长度得到结构体首部指针
    // 结构体类型是不确定的，所以是void *sh
    sh = (char*)s-sdsHdrSize(oldtype);
    newlen = (len+addlen);
    // 如果新长度小于最大预分配长度则分配扩容为2倍
    // 如果新长度大于最大预分配长度则仅追加SDS_MAX_PREALLOC长度
    if (newlen < SDS_MAX_PREALLOC)
        newlen *= 2;
    else
        newlen += SDS_MAX_PREALLOC;
    // 字符串的长度更改了，使用对头部类型可能也会变化
    type = sdsReqType(newlen);
    // 由于SDS_TYPE_5没有记录剩余空间（用多少分配多少），所以是不合适用来进行追加的
    // 为了防止下次追加出现这种情况，所以直接分配SDS_TYPE_8类型
    if (type == SDS_TYPE_5) type = SDS_TYPE_8;

    hdrlen = sdsHdrSize(type);
    if (oldtype==type) {
        // 类型没变化则直接使用原起始地址重新分配下内存即可
        newsh = s_realloc(sh, hdrlen+newlen+1);
        if (newsh == NULL) return NULL;
        s = (char*)newsh+hdrlen;
    } else {
        /* Since the header size changes, need to move the string forward,
         * and can''t use realloc */
        // 头部类型有变化则重新开辟一块内存并将原先整个SDS拷贝一份过去
        newsh = s_malloc(hdrlen+newlen+1);
        if (newsh == NULL) return NULL;
        memcpy((char*)newsh+hdrlen, s, len+1);
        // 旧的已经没用了
        s_free(sh);
        s = (char*)newsh+hdrlen;
        // 配置新类型
        s[-1] = type;
        sdssetlen(s, len);
    }
    // 设置新对分配对总长度
    sdssetalloc(s, newlen);
    return s;
}
```','蔡博','2017-08-26 22:39:02',0);

INSERT INTO ARTICLE (`ID`,`TITLE`,`TAG`,`SUMMARY`,`CONTENT`,`CREATOR`,`CREATION_DATE`,`REVISION`)
VALUES (1011,'JVM类加载3-准备','标签1，标签2','这是文章的摘要',
'笔者博客地址：https://charpty.com


在前两篇文章中，我们讲到JVM已经把class文件加载为运行时数据结构并做了严格的校验，此时的```instanceKlass```需要进行进一步的数据上的处理才能交付使用，准备阶段就是其中相对简单的一步，这一步做的工作并不多，引用Oracle官方文档的话来说:

> Preparation involves creating the static fields for a class or interface and initializing such fields to their default values (§2.3, §2.4). This does not require the execution of any Java Virtual Machine code; explicit initializers for static fields are executed as part of initialization (§5.5), not preparation.

“准备"阶段是为class或者interface中的静态变量赋初始值，这其中的“赋值”并不是大家在Java代码为各个静态变量的赋值操作法，原文也明确了，准备阶段并不会执行任何大家写的Java代码，执行Java字节码的动作在后面的“初始化”阶段执行。举个例子：
``` java
public class StaticFiledTest {
// 在准备阶段，变量var的值会被赋为0而不是2017
public static int var = 2017;
}
```

所以，"准备"阶段赋的初始值仅仅和这个静态变量的类型相关，和在Java代码中对这个变量赋的值无关，Oracle对类型不同的各种变量应该分别赋予何种初始值做出了规定。HotSpot的实现流程如下：
![初始化基本流程](http://img.blog.csdn.net/20170308222244962?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvenN0dV9jYw==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

### 发生时间
“准备”动作可以发生在```instanceKlass```被创建后的任何时间，但是必须在“初始化”动作之前，前面我们也说到HotSpot在代码实现有穿插，“准备”阶段的代码一小部分就在“加载”阶段的```classFileParser.cpp```中（入口与准备工作），主要赋值部分则在```instanceKlass.cpp```中，在此处，类中的静态变量初始化发生在类刚刚被加载后：
![准备阶段触发时机](http://img.blog.csdn.net/20170307234703926?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvenN0dV9jYw==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)
``` c
// javaClass.cpp create_mirror() 495行
// 第一个参数是函数指针，是赋值的关键函数
instanceKlass::cast(k())->do_local_static_fields(&initialize_static_field, CHECK_NULL);
```

### 基本类型赋值
刚开始工作经常被问的一道面试题，Java中一共有哪些基本类型呀，答不上来可就麻烦了。截止Java7，Java中一共有8种基本类型，分别是byte、short、int、long、char、float、double、boolean，但在JVM中一共有9种基本类型，多出来的一种是returnAddress类型。

1. ```byte``` 用8位补码表示，初始化为0
2. ```short``` 用16位补码表示，初始化为0
3. ```int``` 用32位补码表示，初始化为0
4. ```long``` 用64位补码表示，初始化为0L
5. ```char``` 用16位补码表示，初始化为"\u0000"，使用UTF-16编码
6. ```float``` 初始化为正0
7. ```double ``` 初始化为正0
8. ```boolean``` 初始化为0
9. ```returnAddress``` 初始化为字节码指令的地址,用于配合异常处理特殊指令

在```classFileParser.cpp```中（parse_fields()）有一段对各个类型赋值的预处理：
![根据不同类型赋值](http://img.blog.csdn.net/20170307233237953?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvenN0dV9jYw==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

### 引用类型赋值
有三种引用类型：类类型、数组类型和接口类型，他们都将被赋值为null，null可以被转换为任意类型

### 特殊赋值场景
前面说到，JVM在“准备”阶段对静态变量的赋值和Java代码无关，大多数情况下确实如此，但也存在特殊情况。
赋值时会扫描类的字段属性表，如果此时发现有```ConstantValue```属性，那么在“准备”阶段就会将静态属性的值赋为```ConstantValue```指定的值。如何生成```ConstantValue```属性呢？在Java语言中，只要将静态变量声明为final即可。
```
public class StaticFiledTest {
// 声明为final后var的值在准备阶段则会被赋为2017
public static final int var = 2017;
}
```
其实这个特殊前面的讲解中也已提到，解析*.class文件中的属性表时，会把各个属性的```constantvalue_index```取出并存入```instanceKlass```中，后续赋值时也是从此处来取。
```
// 解析Field的attribute_info属性，其中包括ConstantValue
parse_field_attributes(cp, attributes_count, is_static, signature_index, &constantvalue_index, &is_synthetic,
&generic_signature_index .......);

fields->short_at_put(index++, access_flags.as_short());
fields->short_at_put(index++, name_index);
fields->short_at_put(index++, signature_index);
// 将constantvalue_index存入结构体中，用于后续给静态变量赋值
// 放入数组的下标为3
fields->short_at_put(index++, constantvalue_index);
```
何种条件下才会触发在“准备”阶段就赋值呢？HotSpot的```javaClasses.cpp```中给出了答案：
```
static void initialize_static_field(fieldDescriptor* fd, TRAPS) {
// 创建句柄以及是否静态校验
.......
// 如果存在有初始值即constantvalue_index是有效的则赋值
// constantvalue_index存放位置为属性数组的第4个值（index=3）
if (fd->has_initial_value()) {
BasicType t = fd->field_type();
switch (t) {
// 根据不同类型赋值
......
```

> 参考文档：
> https://docs.oracle.com/javase/specs/jvms/se7/html/jvms-5.html#jvms-5.4.2','蔡博','2017-08-27 22:39:02',0);

INSERT INTO ARTICLE (`ID`,`TITLE`,`TAG`,`SUMMARY`,`CONTENT`,`CREATOR`,`CREATION_DATE`,`REVISION`)
VALUES (1012,'HttpInvoker运作原理','标签1，标签2','这是文章的摘要',
'> 笔者博客地址：https://charpty.com
> Spring源码解析系列均基于Spring Framework 4.2.7

### 把第三方系统的方法搬到本地
HttpInvoker是常用的Java同构系统之间方法调用实现方案，是众多Spring项目中的一个子项目。顾名思义，它通过HTTP通信即可实现两个Java系统之间的远程方法调用，使得系统之间的通信如同调用本地方法一般。

HttpInvoker和RMI同样使用JDK自带的序列化方式，但是HttpInvoker采用HTTP方式通信，这更容易配合防火墙、网闸的工作。
## 服务端实现
服务端主入口由```HttpInvokerServiceExporter```实现，它的工作大致流程如下
![服务端处理流程](http://img.blog.csdn.net/20170127140225085?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvenN0dV9jYw==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

```HttpInvokerServiceExporter```实现了```HttpRequestHandler```，这使得其拥有处理HTTP请求的能力，按照Spring MVC的架构，它将被注册到```HandlerMapping```的```BeanNameMapping```中，这设计到Spring MVC如何处理请求，可以关注我的相关文章。
服务端的重要任务就是读取并解析```RemoteInvocation```，再返回```RemoteInvocationResult```，剩下的都只是标准IO流的读写。

## 客户端实现
客户端的实现也很好理解，主入口为```HttpInvokerProxyFactoryBean```, 和Spring用到的众多设计相同，该类的结构使用了模板设计方法，该类提供实现了几个模板方法，整体逻辑由父类```HttpInvokerClientInterceptor```的实现，主要流程如下
![客户端处理流程](http://img.blog.csdn.net/20170127141431409?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvenN0dV9jYw==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

我们最关心的是当我们调用接口的方法时，```HttpInvoker```是如何做到调用到远方系统的方法的，其实```HttpInvokerProxyFactoryBean```最后返回的是一个代理类（Cglib Proxy或者Jdk Proxy），我们调用接口的任何方法时，都会先执行```HttpInvokerClientInterceptor```的```invoke()```方法。

```
public Object invoke(MethodInvocation methodInvocation) throws Throwable {
// 如果是调用toString()方法则直接本地打印下方法信息
if (AopUtils.isToStringMethod(methodInvocation.getMethod())) {
return "HTTP invoker proxy for service URL [" + getServiceUrl() + "]";
}
// 构建RemoteInvocation对象，服务器和客户端统一使用该类进行通信
RemoteInvocation invocation = createRemoteInvocation(methodInvocation);
RemoteInvocationResult result;
try {
// 使用JDK自带的HttpURLConnection将序列化后的invocation的发送出去
  result = executeRequest(invocation, methodInvocation);
} catch (Throwable ex) {
  throw convertHttpInvokerAccessException(ex);
}
try {
  return recreateRemoteInvocationResult(result);
}
catch (Throwable ex) {
  if (result.hasInvocationTargetException()) {
   throw ex;
  }
 else {
  throw new RemoteInvocationFailureException("Invocation of method [" + methodInvocation.getMethod() +
"] failed in HTTP invoker remote service at [" + getServiceUrl() + "]", ex);
}
}
}

```
### 小结
HttpInvoker的实现就像学TCP编程时的“时间服务器”一样，是个经典且容易理解的HTTP通信编程范例，结合Java的序列化和简单的封装，让程序员可以像调用本地方法一样调用第三方服务器的方法，非常方便。','蔡博','2017-08-28 22:39:02',0);


INSERT INTO ARTICLE (`ID`,`TITLE`,`TAG`,`SUMMARY`,`CONTENT`,`CREATOR`,`CREATION_DATE`,`REVISION`)
VALUES (1013,'JVM类加载1-加载','标签1，标签2','这是文章的摘要',
'> 笔者博客地址：https://charpty.com

JVM(本系列统指sun的HotSpot虚拟机1.7版本实现)加载类一共分为5步，分别是：1、加载 2、验证 3、准备 4、解析 5、初始化，简要的流程图如下
![这里写图片描述](http://img.blog.csdn.net/20170204141610870?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvenN0dV9jYw==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)

“加载”是“类加载”的第一个步骤，“类加载”的总指挥是```ClassLoader```，加载步骤大多都是异步的，各个阶段都有交叉进行甚至仅在需要时才进行（如晚解析），不像图中这样规矩。但按照JVM规范中指明**"A class or interface is completely loaded before it is linked"**，所以虽然HotSpot实现有特性，但“加载”可以认为是同步的，且只有当“加载”步骤完成后才能进行后续动作。

“加载”，顾名思义就是要将*.class的文件读到内存中，读成虚拟机可以认识的结构体，做的事情比较简单，我们可以把它细化成3件事：

 1. 读取此类的二进制字节流
 2. 将字节流转换为运行时的数据结构
 3. 生成java.lang.Class对象

“加载”的动作主要在**classLoader.cpp(指包含类的子类)**和**classFileParser.cpp**文件中实现，在笔者看的1.7版本中，后者有4689行代码，算是篇幅比较大的类（C++）了。

### 一、读取此类的二进制字节流
 拿本地文件系统来说，读取一个类的二进制流无非就是读本地的一个*.class文件，但是JVM规范并没有限定一定要从本地读取类的二进制字节流，这给开发人员提供了很大的想象空间，目前很多的类加载技术都是依托于这点，举几个例子：

 1. 大家熟悉的JSP应用，JSP文件会自动生成Class类
 2. 从jar包（war包）中读取*.class文件，这让大家可以方便的把自己的项目打包并部署到WEB容器中
 3. Cglib或者其它asm操作库，它们可以动态的生成类的二进制字节流，这就使得动态代理技术得以实现


读取的方式不受限制，这让加载方式有无限扩展的可能，在各种云时代的今天，甚至可以全部通过网络来加载类的二进制字节流（Java的Applet应用就是从网络中加载）。

读取后最终会以```ClassFileStream```类来表示，读取方式是多种多样的，所以HotSpot实现时将读取的方法写成了纯虚函数以实现多态：
```
// classLoader.hpp[Class=ClassPathEntry]  66行
// Attempt to locate file_name through this class path entry.
// Returns a class file parsing stream if successfull.
virtual ClassFileStream* open_stream(const char* name) = 0;
```
如果读取成功则会返回```ClassFileStream```对象的指针，提供给后续步骤使用。


### 二、将字节流转换为运行时的数据结构
在获取到正确的```ClassFileStream```对象指针后，则会创建一个```ClassFileParser```实例并调用其```parseClassFile()```方法来解析```ClassFileStream```结构。其实第二、三步都在这个方法中，将其区分开来主要是为了方便理解两个步骤各自的功能。
现在所做的步骤更多的是读取值并进行简单的校验，包括JVM规范所说的**“Format Checking”**（校验*.class文件内容是否符合JVM关于class文件结构的定义），需要说明的是，这里一小部分的校验内容其实是“验证”阶段的工作（代码和“加载”混在一起），后续还会提到，需要获取或校验的值大致有：

 1. 读取魔数并校验
 魔数中有代表*.class文件编译时的版本信息，例如被JDK1.8编译过来的class文件不能被JDK1.7的虚拟机加载，逻辑很好理解，这是一个强校验，没有商量的余地，高版本的*.class文件不能被低版本的虚拟机加载，即使恰好这个class文件没有使用高版本特性也不行
 2. 获取常量池引用
 常量池信息主要包含两类，字面量和符号引用，字面量主要指文本字符串，声明为final的常量值等，符号引用主要包含父类或实现接口，字段和方法的名称和描述符
 3. 读取访问标志表示并校验
标志用于识别类或者接口层次的访问信息，例如：该Class是类还是接口，是否被public修饰，是否是抽象类
 4. 获取this类全限定名
 读取当前类索引，并在常量池中找到当前类的全限定名，前面在读取常量池信息时，解析器获得了一个常量池句柄，可以通过它和自身的```index```获取本类的在常量池中存储的全限定名
![这里写图片描述](http://img.blog.csdn.net/20170131130941313?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvenN0dV9jYw==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)
后面会对这个名称做一些基本的校验，正如图中所见，如果没问题则赋值给本地解析器变量以便后续处理
 5. 获取父类以及接口信息
 如果有继承父类或者实现接口，那么父类或接口需要被先加载，如果已经加载则获取它们的句柄记录到本类中，过程中会做一些简单的名称之类的校验
 6. 读取字段信息和方法信息
 读取字段信息存储到typeArrayHandle中，读取实例方法信息并存储到objArrayHandle中，这两部分信息在后续步骤都会填入instanceKlass对象中，成为类信息的一部分。
![这里写图片描述](http://img.blog.csdn.net/20170131133514912?watermark/2/text/aHR0cDovL2Jsb2cuY3Nkbi5uZXQvenN0dV9jYw==/font/5a6L5L2T/fontsize/400/fill/I0JBQkFCMA==/dissolve/70/gravity/SouthEast)
 字段和方法信息读取完成之后，还会进行排序以便后续对Class大小进行评估，需要注意的是当一个Java中的Class在被加载之后，它的大小就是固定的了。

### 三、生成java.lang.Class对象
前面已经读取到了*.class文件中的所有信息，接下来要做的就是进行一些计算并创建好Class对象以供其它阶段使用

 1. 计算Java vtable和itable大小
 根据已解析的父类、方法、接口等信息计算得到Java vtable（虚拟函数表）和itable（接口函数表）大小，这是后续创建klassOop时需要指定的参数
 当然还包括一些其它信息的计算，例如属性偏移量等，这里不一一列举
 2. 创建instanceKlass对象
```
     // We can now create the basic klassOop for this klass
    klassOop ik = oopFactory::new_instanceKlass(name, vtable_size, itable_size,XXX....., CHECK_(nullHandle));
    // 前面做的诸多工作都是为了创建这个对象
    instanceKlassHandle this_klass (THREAD, ik);
```
前面做了许多的工作，读取并解析了类的各种信息，终于到了创建一个用来表示这些类信息的结构的时候，```instanceKlass```负责存储*.class文件对应的所有类信息，创建完成之后，还会进行一些基本的校验，这些校验都是和语言特性相关的，所以不能像校验字符串级别的特性一样放在前面处理，校验的项大致如：check_super_class_access（父类可否继承）、check_final_method_override（是否重写final方法）等
 3. 创建Java镜像类并初始化静态域
```
// Allocate mirror and initialize static fields
java_lang_Class::create_mirror(this_klass,CHECK_(nullHandle));
// 通知虚拟机类已加载完成
ClassLoadingService::notify_class_loaded(instanceKlass::cast(this_klass()), false);
```
通过克隆```instanceKlass```创建一个Java所见的```java.lang.Class```对象并初始化静态变量，这个处理方式和JVM对于对象和类的表示方法有关系，后续会讲到。最后还需要通知虚拟机，更新```PerfData```计数器，“加载”阶段完成之后，虚拟机就在方法区为该类建立了类元数据。

## 小结
“加载”是“类加载”后续步骤的基石，JVM的规范体现了跨平台、跨语言的宏观理念，使用JVM上语言的同学可以不追究细节，但都应该了解“加载”的三小步。对Java程序员来说，这对写出可以在各个容器下稳定运行的代码是很重要的，对于解决平常遇到的“本地可运行，发布后不稳定”、“Tomcat下能运行Weblogic不能”、“log4j优先加载哪一个配置文件”等等问题有一定的帮助。
对于“加载”，HotSpot的实现代码非常庞大，所幸源码中有良好的注释，这提醒了我良好注释的重要性。


Oracle官方的文档对我的帮助很大
>参考： https://docs.oracle.com/javase/specs/jvms/se7/html/jvms-5.html','蔡博','2017-08-28 22:39:02',0);


INSERT INTO ARTICLE (`ID`,`TITLE`,`TAG`,`SUMMARY`,`CONTENT`,`CREATOR`,`CREATION_DATE`,`REVISION`)
VALUES (1015,'Spring源码解析之Bean的加载','标签1，标签2','这是文章的摘要',
'本文基于Spring4.2.7版本，由于Bean的处理是Spring的核心模块，所以版本之间也没有太大的差异

## 从源码中看端倪
相信大家多少有些基本的概念了，我们就从源码中来看看Spring是如何加载Bean的。
```java
java
 // 从IOC容器中获取bean的基本方法
 // 了解Spring的同学应该知道，getXXX往往是预处理，doGetXXX才是真正的获取
  @SuppressWarnings("unchecked")
  protected <T> T doGetBean(
      final String name, final Class<T> requiredType, final Object[] args, boolean typeCheckOnly)
      throws BeansException {

// 如果是bean的别名或者bean的工厂名都会在这里处理掉
// bean的工厂名(bean名称前加&符号)也是Spring用于防止循环依赖和松耦合的创新方法
    final String beanName = transformedBeanName(name);
    Object bean;

    // 首先在单例集合中取，大多数情况下，交给IOC管理的Bean都是单例的
    // 而且也只有单例模式会存在循环依赖的问题
    Object sharedInstance = getSingleton(beanName);
    // 如果指定了参数的
    if (sharedInstance != null && args == null) {
    // 这里有个小技巧，先判断能否输出日志，再进行组装字符串，避免费劲组装了一大堆字符串却又不需要输出的情况，在工作中可以借鉴
      if (logger.isDebugEnabled()) {
        if (isSingletonCurrentlyInCreation(beanName)) {
          logger.debug("Returning eagerly cached instance of singleton bean ''" + beanName +
              "'' that is not fully initialized yet - a consequence of a circular reference");
        }
        else {
          logger.debug("Returning cached instance of singleton bean ''" + beanName + "''");
        }
      }
      ////根据给定的实例是否为工厂Bean，返回它自己或工厂Bean创建的实例
      bean = getObjectForBeanInstance(sharedInstance, name, beanName, null);
    }

    else {
      if (isPrototypeCurrentlyInCreation(beanName)) {//如果正在被创建，就抛出异常
        throw new BeanCurrentlyInCreationException(beanName);
      }

      BeanFactory parentBeanFactory = getParentBeanFactory();//取本容器的父容器
      if (parentBeanFactory != null && !containsBeanDefinition(beanName)) {//若存在父容器，且本容器不存在对应的Bean定义
        String nameToLookup = originalBeanName(name);//取原始的Bean名
        if (args != null) {//若参数列表存在
          // 那么用父容器根据原始Bean名和参数列表返回
          return (T) parentBeanFactory.getBean(nameToLookup, args);
        }
        else {
          // 参数列表不要求，那就直接根据原始名称和要求的类型返回
          return parentBeanFactory.getBean(nameToLookup, requiredType);
        }
      }

      //如果不需要类型检查，标记其已经被创建
      if (!typeCheckOnly) {
        markBeanAsCreated(beanName);
      }

      //根据beanName取其根Bean定义
      final RootBeanDefinition mbd = getMergedLocalBeanDefinition(beanName);
      checkMergedBeanDefinition(mbd, beanName, args);

      String[] dependsOn = mbd.getDependsOn();//得到这个根定义的所有依赖
      if (dependsOn != null) {
        for (String dependsOnBean : dependsOn) {
          getBean(dependsOnBean);//注册这个Bean
          //注册一个Bean和依赖于它的Bean（后参数依赖前参数）
          registerDependentBean(dependsOnBean, beanName);
        }
      }

      // 如果Bean定义是单例，就在返回单例
      if (mbd.isSingleton()) {
        sharedInstance = getSingleton(beanName, new ObjectFactory<Object>() {
          public Object getObject() throws BeansException {
            try {
              return createBean(beanName, mbd, args);
            }
            catch (BeansException ex) {
              destroySingleton(beanName);
              throw ex;
            }
          }
        });
        //根据给定的实例是否为工厂Bean，返回它自己或工厂Bean创建的实例
        bean = getObjectForBeanInstance(sharedInstance, name, beanName, mbd);
      }
      //如果是原型
      else if (mbd.isPrototype()) {
        // It''s a prototype -> create a new instance.
        Object prototypeInstance = null;
        try {
          beforePrototypeCreation(beanName);//原型创建前，与当前线程绑定
          prototypeInstance = createBean(beanName, mbd, args);
        }
        finally {
          afterPrototypeCreation(beanName);//原型创建后，与当前线程解除绑定
        }
        bean = getObjectForBeanInstance(prototypeInstance, name, beanName, mbd);
      }

      else {//既不是单例又不是原型的情况
        String scopeName = mbd.getScope();
        final Scope scope = this.scopes.get(scopeName);//得到范围
        if (scope == null) {
          throw new IllegalStateException("No Scope registered for scope ''" + scopeName + "''");
        }
        try {//根据范围创建实例
          Object scopedInstance = scope.get(beanName, new ObjectFactory<Object>() {
            public Object getObject() throws BeansException {
              beforePrototypeCreation(beanName);
              try {
                return createBean(beanName, mbd, args);//原型创建前，与当前线程绑定
              }
              finally {
                ////原型创建后，与当前线程解除绑定
                afterPrototypeCreation(beanName);
              }
            }
          });
          //根据给定的实例是否为工厂Bean，返回它自己或工厂Bean创建的实例
          bean = getObjectForBeanInstance(scopedInstance, name, beanName, mbd);
        }
        catch (IllegalStateException ex) {
          throw new BeanCreationException(beanName,
              "Scope ''" + scopeName + "'' is not active for the current thread; " +
              "consider defining a scoped proxy for this bean if you intend to refer to it from a singleton",
              ex);
        }
      }
    }
```','蔡博','2017-08-28 22:39:02',0);


INSERT INTO ARTICLE (`ID`,`TITLE`,`TAG`,`SUMMARY`,`CONTENT`,`CREATOR`,`CREATION_DATE`,`REVISION`)
VALUES (1016,'Spring中的设计模式--工厂方法模式','标签1，标签2','这是文章的摘要',
'> 小编博客地址：https://charpty.com

## 关于工厂方法模式的误会
不太在意设计模式的同事会对工厂模式有极深的误解，总会把“工厂模式”与“静态工厂方法”混为一谈，什么是静态工厂方法？看一个简单的例子：
``` java
public class SimpleClientFactory {

	public static Client createClient(){
		return new Client();
	}
}
```
通过一个静态方法来创建实例，这种方式在代码中比较常见，但这并不是我们今天要说的工厂模式，它只是一个“静态工厂方法”。
个人觉得很难给模式一个语句上的定义，因为这些模式本身只是一些帮助我们养成好的代码习惯的一些建议，它们甚至算不上是一种规范。对于工厂模式，我觉得某一段定义说的是比较准确的。

**父类定义了创建对象的接口，但是由子类来具体实现，工厂方法让类把实例化的动作推迟到了子类当中。**

也就是说，父类知道什么时候该去创建这个对象，也知道拿到这个对象之后应该对这个对象做什么事情，但是不知道如何去创建这个对象，对象的创建由子类来完成。
之所以有这种设计模式，也是多年业务逻辑的积累导致，大多数业务场景下，对某一类对象总是要执行相同的流程，但是并不在意这些对象之间的微小差异，这种业务场景就非常符合工厂模式的设计。公共的父类决定了怎么去处理这一类对象，而子类决定了如何创建这些有着微小差异的不同对象。

既然是工厂方法模式，那什么是“工厂方法”？举个基础的例子：
``` java
// 这是一个网页爬虫类，它利用HttpClient来获取数据并分析
public abstract class WebCrawler {

	// 爬取网页数据
	public WebResult getWebInfo(String url) {
		HttpClient c = getClient();
		HtmlResult res = c.getPage(url);
		return processHtml(res);
	}

	// HttpClient是接口或者抽象类，下文统称为接口
	private HttpClient getClient() {
	    // 如果缓存中不存在client则创建
		HttpClient c = getFromCache();
		if (c == null) {
			c = createClient();
		}
		// 创建之后对client进行初始化
		initClient(c);
	}

	 // 提供一个抽象让子类来实现创建client
	 // 这个抽象方法就是“工厂方法”
	 protected abstract HttpClient createClient();
}
```

``` java
// A和B类型两种client工厂都不需要关心创建client前的逻辑判断以及创建后的流程处理，他们只关心创建对象

class ATypeCrawler extends WebCrawler {

	HttpClient createClient() {
		return new ATypeClient();
	}
}

class BTypeCrawler extends WebCrawler {
	HttpClient createClient() {
		return new BTypeClient();
	}
}

```
工厂方法模式能够封装具体类型的实例化，**```WebCrawler```提供了一个用于创建```HttpClient```的方法的接口，这个方法也称为“工厂方法”**，在```WebCrawler``` 中的任何方法在任何时候都可能会使用到这个“工厂方法”，但由子类具体实现这个“工厂方法”。


## Spring中的工厂模式
Spring源码中有非常多的地方用到了工厂模式，几乎是无处不见，但是笔者决定拿大家最为常用的Bean来说，用Spring很多程度上是依赖它的对象管理，也就是IoC容器对于Bean的管理，Spring的IoC容器如何创建和管理Bean其实是比较复杂的，它并不在我们此次的讨论范围中。我们关心的是Spring如何利用工厂模式来实现了更加优良J2EE松耦合设计。
接下来我们就一起查看一下Spring中非常重要的一个类```AbstractFactoryBean```是如何利用工厂模式的。
``` java
// AbstractFactoryBean.java
// 继承了FactoryBean，工厂Bean的主要作用是为了实现getObject()返回Bean实例
  public abstract class AbstractFactoryBean<T> implements FactoryBean<T>, BeanClassLoaderAware, BeanFactoryAware, InitializingBean, DisposableBean {

// 定义了获取对象的前置判断工作，创建对象的工作则交给了一个抽象方法
// 这里判断了Bean是不是单例并且是否已经被加载过了（未初始化但加载过了，这个问题涉及到Spring处理循环依赖，以后会讨论到）
  public final T getObject() throws Exception {
        return this.isSingleton()?(this.initialized?this.singletonInstance:this.getEarlySingletonInstance()):this.createInstance();
    }
// 由子类负责具体创建对象
protected abstract T createInstance() throws Exception;
}
```
之所以这么写是因为这种写法带来了两个好处:

**（1） 保证了创建Bean的方式的多样性**
Bean工厂有很多种，它们负责创建各种各样不同的Bean，比如Map类型的Bean，List类型的Bean，Web服务Bean，子类们不需要关心单例或非单例情况下是否需要额外操作，只需要关心如何创建Bean，并且创建出来的Bean是多种多样的。

**（2） 严格规定了Bean创建前后的其它动作**
虽然子类可以自由的去创建Bean，但是创建Bean之前的准备工作以及创建Bean之后对Bean的处理工作是AbstractFactoryBean设定好了的，子类不需要关心，也没权力关心，在这个例子中父类只负责一些前置判断工作。

工厂方法模式非常的有趣，它给了子类创建实例的自由，又严格的规定了实例创建前后的业务流程。

## 依赖倒置原则

 工厂方法模式非常好的诠释了面向对象六大设计原则之一的依赖倒置原则：要依赖抽象，不要依赖具体类。
 对依赖倒置的原则这个解释有点过于笼统，不太好理解，到底是哪些依赖被倒置了呢？
 回想最开始的基础例子，如果不使用工厂模式，我们的代码可能是这样的
```
public class WebCrawler {

	public WebResult getWebInfo(int clientType, String url) {
		HttpClient c = getClient(clientType);
		HtmlResult res = c.getPage(url);
		return processHtml(res);
	}

	private HttpClient getClient(int clientType) {
		HttpClient c = getFromCache();
		if (c == null) {
			c = createClient(clientType);
		}
		initClient(c);
	}

	 // 根据不同的类型参数来创建不同的HttpClient
	private HttpClient createClient(int clientType){
		if (clientType == 1) {
			return ATypeClient();
		} else if (clientType == 2) {
			return BTypeClient();
		} else if (clientType == 3) {
			return CTypeClient();
		} else
			......
	}
}
```
上述代码最大的问题就是违背了开放-关闭原则，对扩展开放，对修改关闭。当有新的```HttpClient ```加入，则需要修改```WebCrawler ```类的代码，但是```WebCrawler ```并不关心具体的```HttpClient ``` 的具体类型，它只知道可以使用```HttpClient ```来获取网页信息，然后它自己就可以对这些网页信息就行分析。目前的代码写法导致```WebCrawler ```依赖于具体的```HttpClient ```实现类。

如果使用工厂模式，则可以避免这样的尴尬，工厂模式使得```WebCrawler ```不必关心```HttpClient ``` 的具体类型，因为这些具体的```HttpClient ``` 是由子类具体创建的，自己根本不知道到底有哪些```HttpClient ```类型，它只关心使用。同样的，各个子类也只管着创建```HttpClient ``` 的实例，至于这些实例被拿去做什么事情，什么时候做，它们并不知情。

按理说，高层组件应该依赖于低层组件，低层组件为高层组件提供一些最基础的服务，但是工厂模式倒置了这一依赖现象，让低层组件反而要依赖于统一的抽象接口。
**工厂模式让高层组件（WebCrawler）和低层组件（ATypeClient|BTypeClient|......）都依赖于共同的接口（HttpClient），这倒置了原本的依赖模型，解除了高层组件和低层组件之间的强依赖关系**


## 小结
工厂模式是非常常用且容易理解的设计模式，它也很好的诠释了六大原则之一的依赖倒置原则，能够帮助写出松耦合且方便扩展的代码。
要知道，在程序的世界，唯一不变的就是变化的需求，所以代码的可扩展性相当重要。','蔡博','2017-08-28 22:39:02',0);


INSERT INTO ARTICLE (`ID`,`TITLE`,`TAG`,`SUMMARY`,`CONTENT`,`CREATOR`,`CREATION_DATE`,`REVISION`)
VALUES (1017,'使用gdb调试Nginx worker进程','标签1，标签2','这是文章的摘要',
'> 笔者博客地址：https://charpty.com

在开发Nginx模块或者遇到难以解决的Nginx配置问题时，不得不通过调试手段来找出问题所在，本文通过在Linux系统上使用gdb工具来演示如何调试运行中的Nginx进程，本文只关心Nginx的实际执行者--worker进程。


###（1）编译Nginx
首先你需要编译出带有调试信息的可执行文件和.o文件。
获得Nginx源码之后，通过我们熟悉的```configure```命令指定稍后make时需带有debug信息。
```shell
./configure --with-debug
```
之后直接调用相应命令编译Nginx源码即可
```shell
make
```
此时，在源码录下生成了一个objs目录，该目录下包含了带有调试信息的可执行文件和.o文件，是我们调试的关键，我们稍后的调试过程都将在这个目录下进行。

###（2）配置和启动Nginx
这里可以大家需要根据自己遇到的问题来配置自己的nginx.conf，在源码目录的conf文件夹下提供了默认的nginx.conf，由于本文只是一个示例，我们就采用Nginx的静态文件模块（```ngx_http_static_module```）来进行调试，也就是默认的nginx.conf中指定的:
```shell
    location / {
        root   html;
        index  index.html index.htm;
    }
```
这样的话，我们不需要这个配置文件进行任何改动，直接启动Nginx并指定这个Nginx提供的默认配置文件即可。

还有一点需要特别说明下，这个默认的配置文件中，也指定了worker进程的数量是1，这样无形中方便了我们进行调试
```
worker_processes  1;
```

启动方式也很方便，进入到我们刚才编译出来的objs目录下，其中有一个名为 ```nginx```的可执行文件
```shell
cd objs
# 这里需要指定一下源码中默认提供的nginx.conf的绝对路径
./nginx -c /root/nginx-1.9.9/conf/nginx.conf
```
通过```-c```选项指定配置文件之后，顺利启动了Nginx，可以查看到Nginx进程已顺利运行
```shell
ps -ef | grep nginx
```

###（3）使gdb能够调试nginx进程

首先当然是启动gdb
gdb启动有许多的模式，为了演示方便，我们使用最为直观的调试方式。
```shell
# -q: 静默模式，不显示版本信息的杂项
# -tui: 可以显示源码界面，即屏幕上方一个长期''l''指令
# 该命令应该在objs目录下执行，这样gdb才能找到源码信息
gdb -q -tui
```
*说明： -tui选项只是为了方便，如果不习惯则直接使用```gdb```命令即可，对后续的讲解无影响。

然后你需要使用gdb的```attach```命令来依附Nginx的worker进程，首先需要获取Nginx worker进程的pid
```
[root@wind4app objs]# ps -ef | grep nginx
root     25733     1  0 21:03 ?        00:00:00 nginx: master process ./nginx -c nginx.conf
nobody   25734 25733  0 21:03 ?        00:00:00 nginx: worker process
```
我们看到Nginx worker进程的pid为```25734```

使用gdb attach命令
```
(gdb) attach 25734
```
此时你已经成功依附Nginx worker进程，可以开始真正的调试了。


###（4）开始gdb调试
现在，我们可以开始真正的调试，整套流程下来很简单，熟悉了之后非常的方便。
现在，我们在想要进行调试的静态文件模块，即```ngx_http_static_ module```处打一个断点，一般来说我们都打在handler函数处，运行期间出现问题的话，大多都是handler函数内含有Bug
```
(gdb) b ngx_http_static_handler
(gdb) c
```

通过```c```选项使进程继续运行，此时一旦有访问发生，就会触发我们的断点。

此时我们可以在浏览器中请求我们的服务器地址，或者通过```curl```命令等方式来触发我们的断点，然后通过灵活的gdb命令对Nginx模块进行调试。  ','蔡博','2017-08-28 22:39:02',0);


INSERT INTO ARTICLE (`ID`,`TITLE`,`TAG`,`SUMMARY`,`CONTENT`,`CREATOR`,`CREATION_DATE`,`REVISION`)
VALUES (1018,'Nginx优秀设计--ngx_tolower相关宏','标签1，标签2','这是文章的摘要',
'# Nginx优秀设计--ngx_tolower相关宏

Tags: Nginx

---
今天说一个简单的Nginx宏

在Nginx中提供了一个将单个字符转换为小写的宏
```
#define ngx_tolower(c)      (u_char) ((c >= ''A'' && c <= ''Z'') ? (c | 0x20) : c)
```
逻辑比较简单，如果是属于大写字母，则通过位运算得到对应小写字母，如果不是则返回原字符，关键在于这个位运算为什么能返回对应的小写字母。
大小字母A的ASCII为65，小写字母a的ASCII为97，实际上其实大写字母加上32就是对应的小写字母了，那为什么Nginx里要这么写呢？

我们先来手动验证一下```c|0x20```这个表达式能不能将A转换为a：

```
// A -> 65(10) -> 0100 0001(2) -> 41(16)
//                |按位或
// 				  0010 0000(2) -> 0110 0001(2) -> 61(16) -> 97(10) -> a
```
实践证明，是可行的。

其实道理十分简单，把第6位置1，不就是等于加上2的5次方，也就是加上32吗，那么为什么不直接写加上32呢？

这是因为位运算的执行效率要高于执行加法，那为什么位运行的执行效率高呢？
请看以下链接：


同样的
```
// 减32
#define ngx_toupper(c)      (u_char) ((c >= ''a'' && c <= ''z'') ? (c & ~0x20) : c)
```

今天是2016年第一天，新年快乐，早点休息。

','蔡博','2017-08-28 22:39:02',0);


INSERT INTO ARTICLE (`ID`,`TITLE`,`TAG`,`SUMMARY`,`CONTENT`,`CREATOR`,`CREATION_DATE`,`REVISION`)
VALUES (1019,'Nginx的数据结构--字符串','标签1，标签2','这是文章的摘要',
'# Nginx的数据结构--字符串

Tags: Nginx数据结构

---
考虑到跨平台、高效率、统一规范，Nginx封装了许多的数据结构，大多数都是我们在其他开发项目中经常用到的一些，当然还有一些复杂的容器，笔者每篇文章会对其中一至两个点进行分析和练习讲解。

在Nginx中，使用Ngx_str_t表示字符串，它的定义如下：
```
typedef struct {
    size_t      len;
    u_char     *data;
} ngx_str_t;
```
我们可以看到它是一个简单的结构体，只有两个成员，data指针指向字符串起始地址，len表示字符串的长度。
这里你可能会产生疑惑，C语言中的字符串只需要有一个指针就能表示了，为什么这里还需要一个长度呢？这是因为C语言中我们常说的字符串，其实是以''\0''结尾的一串字符，约定俗称的，一旦读取到这个标记则表示字符串结束了，在C++中建立字符串的时候编译器会自动在后面加上''\0''标记。但是Ngx_str_t中的data指针却不是指向C语言中的字符串，而只是一串普通字符的起始地址，这串字符串不会特别的使用''\0''标记作为自己的结尾，所以我们需要len来告诉使用者字符串的长度。
那这样做有什么好处呢？作为网络服务器，Nginx当然更多考虑的这一方便开发的需求，在网络请求中，我们最多接触的就是URL地址，请求头信息，请求实体等，就拿URL地址来说，例如用户请求:
```
GET /test/string?a=1&b=2 http/1.1\r\n
```
那如果我们使用了一个Ngx_str_t结构体来存储了这个值，现在我们想获取请求类型，是GET还是POST或是PUT？我们不需要拷贝一份内存，我们要做仅仅是做一个新的ngx_str_t，里面的data指针是指向和原先的ngx_str_t一个地址，然后将len改为3即可。
当然，这只是个一个最简单的应用，字符串类型几乎是各种业务系统也好，网络框架也好使用十分广泛的一种基本类型，良好的设计结构是Nginx低内存消耗的重要保证。

##ngx_str_t的操作
有了字符串这个简单的一个结构体其实并不是特别的方便，在Java，Python这样的现代高级语言中，都提供了丰富对于字符串类型的操作，Nginx也提供了不少的字符串操作公共函数，尽管有些看上去并不是那么容易用好，那么我们来一一看下这些函数。

在Ngx_string.h文件中定义了许多Nginx字符串操作函数或宏

###（1）字符串初始化相关宏
Nginx定义了一些用于初始化字符串的基本宏，方便用户用一个常面量字符串来初始化或简单设置一个ngx_str_t结构体。
####1）ngx_string宏
```c++
#define ngx_string(str)     { sizeof(str) - 1, (u_char *) str }
```
这是Nginx提供的用于初始化一个Nginx字符串的宏，传入的是一个普通的字符串，即我们常说的C语言字符串。
也如常见的宏的副作用一样，使用时需要注意不能像调用函数一样去操作。
```
// 错误的写法
ngx_str_t str_a;
str_a = ngx_string("abc");

// 正确的写法
ngx_str_t str_a = ngx_string("abc");
```
这是因为C语言允许给结构体初始化时使用{xxx,xxx}这种形式进行赋值，但是不允许在普通的赋值中使用这类形式，这是一种规定，也就是标准。如果非要推敲一下，个人认为，在初始化时，编译器会衡量 = 号左右两边的表达式，因为左边是一个定义语句，此时编译器可以轻松分辨出右侧的表达式是什么类型，则可以完成赋值，然后在定义完成之后，再想要进行普通的赋值，编译器会先计算 = 号右边的表达式，此时并不能确定子表达式的类型，编译器会直接抛出一个错误。
当然这并不是我们讨论的重点，笔者的意思，在使用这些Nginx提供的宏时，需要注意使用规范。

####2）ngx_null_string宏
```
#define ngx_null_string     { 0, NULL }
```
帮助快速定义一个“空字符串”

####3）ngx_str_set宏
```
#define ngx_str_set(str, text)  \
    (str)->len = sizeof(text) - 1; (str)->data = (u_char *) text
```
前面我们说到，一下写法是错误的。
```
// 错误的写法
ngx_str_t str_a;
str_a = ngx_string("abc");
```
那如果有的时候我们确实需要先定义，后根据情况再赋值，这时我们怎么办呢？这时我们可以使用ngx_str_set宏：
```
ngx_str_t str_a;
str_a = ngx_str_set(&str_a, "abc");
```

####4）ngx_str_null宏
其实我们感觉叫 ngx_str_set_null更好的，它的作用和ngx_str_set类似，就是将一个ngx_str_t结构体设置为“空字符串”。
```
#define ngx_str_null(str)   (str)->len = 0; (str)->data = NULL
```

###（2）C字符串信息获取宏
对于一个字符串，这里说的是C中的字符串，我们经常会查询这个字符串的长度，这个字符串是否包含另外一个字符串，这个字符串第某某位是什么字符等等，Nginx也为我们获取字符串的这一类信息提供了几个宏，它们大多采用C标准库来实现。
当然，也包括函数，由于功能比较单一，所以宏居多。
####1）ngx_strncmp宏
该宏的作用是是指定比较size个字符，也就是说，如果字符串s1与s2的前size个字符相同，函数返回值为0。
```
#define ngx_strncmp(s1, s2, n)  strncmp((const char *) s1, (const char *) s2, n)
```
若s1与s2的前n个字符相同，则返回0；若s1大于s2，则返回大于0的值；若s1 若小于s2，则返回小于0的值。
其实就是一个C标准库函数的使用，不太熟悉的同学可以写个小例子练习一下即可。
####2）ngx_strcmp宏
```
#define ngx_strcmp(s1, s2)  strcmp((const char *) s1, (const char *) s2)
```
同ngx_strncmp宏类似，只不过是比较整个字符串。

####3）ngx_strlen宏
用于得到字符串长度，Nginx习惯性的将其重定义以做到跨平台。
```
#define ngx_strlen(s)       strlen((const char *) s)
```

####4）ngx_strstr宏
```
#define ngx_strstr(s1, s2)  strstr((const char *) s1, (const char *) s2)
```
用于判断字符串s2是否是s1的子串，也即字符串s1是否包含s2。

####5）ngx_strchr宏
```
#define ngx_strchr(s1, c)   strchr((const char *) s1, (int) c)
```
查找字符串s1中首次出现字符c的位置。

####6）ngx_strlchr函数
返回某个字符之后的剩余字符串，前提是在last之前。
```
static ngx_inline u_char *
ngx_strlchr(u_char *p, u_char *last, u_char c)
{
    while (p < last) {

        if (*p == c) {
            return p;
        }

        p++;
    }

    return NULL;
}
```
这个函数是Nginx额外定义的，比如字符串```"Get /app/test?a=1&b=2"```，```last```指向最后一个字符，传入参数```c = ''p''```，则调用这个函数得到的结果是```pp/test?a=1&b=2```字符串的指针。

###（3）字符串操作相关函数
同（2）类似，这里不单单是函数，也存在宏，只不过函数占多数。
我们在实际的业务操作中，免不了多字符串进行尾部追加，截取，格式化输出等操作，同样的Nginx提供了一些简单的操作捷径，能够满足我们大多数的操作需求。

####1）ngx_cpy_mem宏
```
#if (NGX_MEMCPY_LIMIT)

void *ngx_memcpy(void *dst, const void *src, size_t n);
#define ngx_cpymem(dst, src, n)   (((u_char *) ngx_memcpy(dst, src, n)) + (n))

#else

/*
 * gcc3, msvc, and icc7 compile memcpy() to the inline "rep movs".
 * gcc3 compiles memcpy(d, s, 4) to the inline "mov"es.
 * icc8 compile memcpy(d, s, 4) to the inline "mov"es or XMM moves.
 */
#define ngx_memcpy(dst, src, n)   (void) memcpy(dst, src, n)
#define ngx_cpymem(dst, src, n)   (((u_char *) memcpy(dst, src, n)) + (n))

#endif
```
其实这里就将其看作是一个简单的memcpy就好。

####2）ngx_copy函数
```
/*
 * the simple inline cycle copies the variable length strings up to 16
 * bytes faster than icc8 autodetecting _intel_fast_memcpy()
 */

static ngx_inline u_char *
ngx_copy(u_char *dst, u_char *src, size_t len)
{
    if (len < 17) {

        while (len) {
            *dst++ = *src++;
            len--;
        }

        return dst;

    } else {
        return ngx_cpymem(dst, src, len);
    }
}
```
这个函数唯一让人感到困惑的地方在于，为什么少于17的字符串追加，直接使用普通的指针追加即可，而如果长于17则调用libc中的memcpy呢？

其实注释中已经讲的比较清楚，系统拷贝会对较长的字符串的拷贝做优化，也就是说，不是像我们这样指针一个个移动的方式来进行的，但是在这种优化执行之前，它也会做许多的检查还有初始化一些环境，如果本身字符串就比较小的话，这些就完全没必要了，Nginx的作者经过一系列的测试，从经验上得出了小于17个字符串时，还是手动拷贝效率高，当然，是否有理论支持我不太清楚，但我感觉这更像是作者的一个经验值，如果是理论值的话，他的注释应该会列出来如何计算的。

睡觉了睡觉了，明天继续吧。。。。好困
','蔡博','2017-08-28 22:39:02',0);

INSERT INTO ARTICLE (`ID`,`TITLE`,`TAG`,`SUMMARY`,`CONTENT`,`CREATOR`,`CREATION_DATE`,`REVISION`)
VALUES (1020,'Ubuntu 平台下OpenResty的安装','标签1，标签2','这是文章的摘要',
'> 笔者博客地址：https://charpty.com



####源码包准备

我们首先要在[官网](http://openresty.org/)下载OpenResty的源码包。官网上会提供很多的版本，各个版本有什么不同也会有说明，我们可以按需选择下载。笔者选择下载的源码包为ngx_openresty-1.9.3.1.tar.gz。

####相关依赖包的安装
首先你要安装OpenResty需要的多个库
请先配置好你的apt源，配置源的过程在这就不阐述了，然后执行以下命令安装OpenResty编译或运行时所需要的软件包。
```
apt-get install libreadline-dev libncurses5-dev libpcre3-dev \
    libssl-dev perl make build-essential
```
如果你只是想测试一下OpenResty，并不想实际使用，那么你也可以不必去配置源和安装这些依赖库，请直接往下看。

###OpenResty的安装
OpenResty在linux的部署可以通过C程序员非常熟悉的方式进行安装：
```
./configure
make && make install
```
具体的步骤如下：

####（1）将软件包拷贝到Ubuntu系统中
首先通过WinScp或者XFTP等文件传输工具将之前下载的OpenResty包传输到你的Ubuntu系统上，如果你的Ubuntu系统可以直接联网的话，你也可以通过```wget https://openresty.org/download/ngx_openresty-1.9.3.1.tar.gz```命令直接从官网下载OpenResty到当前目录。

####（2）解压openresty软件包
```
tar xzvf ngx_openresty-1.9.3.1.tar.gz
```
一般来说这个命令不会出错，解压之后你会得到一个名为ngx_openresty-1.9.3.1的文件夹，如果解压出错，请尝试重新下载OpenResty。

####（3）配置安装目录及需要激活的组件
现在你可以进入到解压出来的目录下，大致浏览一下目录结构，我们可以看到有一个configure文件，它是一个可执行文件，我们可以通过configure命令来对OpenResty进行一些配置，常见的配置有：
1）OpenResty安装目录： --prefix，不指定则默认为/usr/local/openresty
2） 激活某些组件： with-xxxx
3）禁用某些组件: without-xxxx
OpenResty是在Nginx的基础之上，集成了大量优秀的第三方模块形成的，在OpenResty中，大多数的组件都是默认激活的，只有少数几个组件需要手动指定激活，可以通过下述选项激活这几个组件：
```
--with-lua51
--with-http_drizzle_module
--with-http_postgres_module
--with-http_iconv_module
```

一个完整的配置命令如下：
```
./configure --prefix=/opt/openresty\
	        --without-http_redis2_module \
	        --with-http_postgres_module
```
命令很短，也比较好理解：
1） --prefix=/opt/openresty：将软件安装在/opt/openresty目录下
2） --without-http_redis2_module：禁用redis模块
3） with-http_postgres_module：启用postgres数据库模块

上述命令如果不出错的话则会在当前目录下生成一个makefile文件，这是为我们后续的```make && make install```做准备的，该文件指定了make命令的执行规则。
如果出现了错误，则在控制台会输出控制信息，即失败的原因，为何出错可以根据失败原因进行具体的分析，我在这里简单总结下可能的情况。
1）缺少了依赖库：绝大多数情况都是因为这个错误导致的，可以查看错误提示中具体说明的缺少哪一个库，然后进行安装即可
2）部分库本身BUG：这种情况是非常少见的，除非你在一些特别的Ubuntu版本上进行安装，笔者使用的是Ubuntu 14.04.3 LTS，没有发现任何问题，如果出现这类问题，可以尝试更新一下编译器版本或者该库文件版本

前面我们说到，如果只是想测试一下OpenResty的话，我们可以不安装依赖库，当然在这里配置时也需要禁用几个模块，防止configure命令出错
```
./configure --without-http_rewrite_module --without-http_ssl_module  --without-http_gzip_module
```
禁用了这几个模块之后，即可顺利生成makefile文件，但是仅供测试，少了这几个模块，你就少了很多强大的功能。
####（4）执行安装
完成了安装前的配置，生成了对应的makefile之后，我们就可以进行真正的安装了，命令非常的简单。
```
make && make install
```
执行完该命令之后，OpenResty就安装到了你之前指定的安装目录下了。

###测试安装是否成功
如果你在之前的```make && make install```中没有发现错误的话，一般来说就是安装成功了，但是我们还是进行一个简单的测试以保证我们OpenResty确实成功安装了。

如果你使用的是默认的安装目录，则可以执行以下命令启动OpenResty，如果不是，请改为你指定的路径。
```
/usr/local/openresty/nginx/sbin/nginx
```
正确启动的话则没有任何输出，现在OpenResty已经成功启动并监听了Ubuntu服务器的80端口，你可以打开浏览器，输入你的Ubuntu服务器的IP，则你可以看到"Welcome to nginx!"字样，这说明你的OpenResty服务器已经成功运行了。
你也可以通过直接在Ubuntu服务器上输入以下指令来测试OpenResty是否成功启动
```
curl 127.0.0.1
```
你会看到一小段HTML格式的文本输出。


###设置环境变量方便操作
之前的测试案例中，我们需要切换到软件安装的目录下执行相应的命令，那么有没有办法让我们可以直接在任意目录下都可以使用OpenResty的命令呢，其实也非常的简单，只需要配置一下环境变量PATH即可。
在linux终端输入一个命令之后，它会到PATH环境变量所指定的各个目录下去寻找这个命令，所以我们要做的就是把OpenResty的sbin目录，也就是OpenResty的可执行文件目录设置到PATH环境变量中即可。

在Ubuntu中，也许多方式可以设置环境变量，在许多个文件中添加响应的配置行都能达到设置环境变量的目的，我们这里通过设置用户家目录下的.bashrc文件来实现。
```
vi ~/.bashrc

# 添加下面一行代码即可，笔者一般都添加到文件开头，方便查看
# 注意：冒号后面接的是OpenResty安装的位置的可执行文件目录
# 没有特殊指定安装目录的则是： /usr/local/openresty/nginx/sbin

export PATH=$PATH:/usr/local/openresty/nginx/sbin
```
添加配置之后不会立即生效，我们可以通过source命令来重新加载一下我们的配置文件
```
source ~/.bashrc
```
之后我们就可以在任意位置来使用我们的nginx命令了
```
cd ~
nginx -s reload
```

接下来，我们就可以进入到后面的章节[HelloWorld](helloworld.md)学习。

','蔡博','2017-08-28 22:39:02',0);


INSERT INTO ARTICLE (`ID`,`TITLE`,`TAG`,`SUMMARY`,`CONTENT`,`CREATOR`,`CREATION_DATE`,`REVISION`)
VALUES (1021,'检查gcc编译器是否C++ 11特性','标签1，标签2','这是文章的摘要',
'---
检查编译器是否支持C++11特性

1) 简单的检查
通过一个预编译指令判断
```
#if __cplusplus <= 199711L
  #error This library needs at least a C++11 compliant compiler
#endif
```

2) 完整检查
通过[boost环境变量][1]进行检查


一般来说通过第一种方式简单判断即可


  [1]: http://www.boost.org/doc/libs/1_59_0/libs/config/doc/html/boost_config/boost_macro_reference.html#boost_config.boost_macro_reference.macros_that_describe_c__11_features_not_supported','蔡博','2017-08-28 22:39:02',0);

INSERT INTO ARTICLE (`ID`,`TITLE`,`TAG`,`SUMMARY`,`CONTENT`,`CREATOR`,`CREATION_DATE`,`REVISION`)
VALUES (1022,'teuthology安装部署（2）','标签1，标签2','这是文章的摘要',
'# teuthology install（2）
Tags: teuthology ceph 自动化测试

ceph自动化测试环境teuthology的安装部署具体步骤

再次强调，本文所述均建立在Ubuntu14.0LTS系统之上，这是一个非常普通的系统，也是ceph官方推荐使用的。
本文中所克隆的源，有ceph官方的地址，也有H3C的地址，大家都可以自己选择，并无好坏之分，只是个参考。
本文从简到难，逐层安装，没搞懂的就搜索下，一步步装，不要跳着查看，那样反而会给自己造成麻烦，如果有什么概念上的问题，请参看上一篇文章。

>关于我们：https://charpty.com
>          https://github.com/charpty
>          charpty@google.com

##paddles的安装部署
你也可以按照官方教程进行安装，还是比较简单的。
https://github.com/ceph/paddles


前提：请安装好Ubuntu系统，在虚拟机上和物理机上均可，机器要可以上网，配置好apt-get源，使用163的源，或者sohu的都可以。

（1）按照系统级别依赖
配置好apt-get的源之后，通过执行简单命令即可安装所有依赖
```shell
apt-get install python-dev python-virtualenv postgresql postgresql-contrib postgresql-server-dev-all supervisor

# 如果你的机器没有安装一些我们所需要的基本工具，我并没有办法一一陈述
# 后续碰到了，你可以自行安装，我只能大概提到一些
# git，用于拉取代码
apt-get install git
# python环境，一般默认自带，没有的话可以搜索下安装Python
# pip easy_install，这都是Python中的模块，可自行搜索安装，很简单
```
(2)安装并配置postgresql数据库
这里我们安装9.3版本，该版本稳定成熟。
```shell
# 非常方便的安装方式
apt-get install postgresql-9.3
# 安装完成之后，会默认的创建一个用户postgres，这是postgresql的管理员账户
su – postgres
# 通过该命令进入sql控制台，类似于oracle的sqlplus
psql
```
然后你就会进入sql控制台，接下来你将输入sql命令完成一些基本配置
```sql
-- 第一件事情是为改用户设置密码，以后很多配置文件里面有用到
\password postgres
-- 然后输入你自己喜欢的密码即可，本文将统一采用‘1q2w3e’作为我们的密码
-- 如果你想更换密码，可以通过命令
-- alter user postgres with password ''1q2w3e''，很方便。
```
为自己的数据库的管理员账户配置好密码之后，现在你需要创建一个库的实例，就和oracle中的数据库实例类似，以提供给我们的paddles使用。本文将保持和ceph官方的统一，使用‘paddles’作为我们要创建的数据库名字。
```sql
create database paddles;
-- 通过''\l''命令，我们可以查看到我们刚刚创建好的数据库
\l
-- 然后我们退出sql控制台，或者你可以直接按ctrl+d
\q
```
然后我们回到root的操作模式下
```shell
# 为paddles的安装创建一个用户，并设置密码
# 本文中我们将创建名为‘paddles’的用户用于运行paddles
useradd -m paddles -g root -G root
# 为改账号设置密码
echo paddles:1q2w3e | chpasswd
# 创建完成之后，我们切换到paddles用户下操作
su - paddles
```
我们在创建paddles账号时并没有指定它的bash，如果你直接登录到paddles用户会有一些问题，所以我们都是直接先连接到root，然后再切换到paddles上即可。
```shell
# 从github上克隆我们需要的代码
git clone https://github.com/ceph/paddles.git
# 或者你可以使用我们的 git clone https://github.com/H3C/paddles.git
# 下载好之后，进入到下载的文件夹中，执行
# 该命令为创建Python引以为傲的沙盒环境
# 沙盒大概是指该沙盒中的环境是独立，与系统环境互不干扰
virtualenv ./virtualenv
# 配置我们的config.py文件，从模板中复制一份然后修改，这种方式会很常见
cp config.py.in config.py
vi config.py

# 我们主要改两行，一个是server配置项，改成我们自己要监听的地址
# 一般就是本机的ip，监听端口我选择了8080，你可以随意，只要各处统一就好
server = {
    ''port'': ''8080'',
    ''host'': ''172.16.38.101''
}

# 还有一处要修改的就是数据库的地址，在最下方
# 我们使用的是postgresql数据库，这里我们将之前配置的数据库信息填上
# 注释掉默认的url行，增加我们自己的
# 这个位置其实就是Python语法中的map，别忘记在逗号
''url'' : ''postgresql://postgres:1q2w3e@localhost/paddles'',


# 进入沙盒环境
source ./virtualenv/bin/activate
# 然后你就会发现自己的命令行前面表面你已经进入到沙盒环境中了
# 安装沙盒需要的相关依赖
pip install -r requirements.txt
# 初始化环境
python setup.py develop
# 创建表，也即在postgresql创建和初始化paddles需要的表结构
# 这里我一度官方的修改会导致这一步出问题
# 所以如果你在这里也遇到了问题，你可以使用前面说的H3C的源代码
pecan populate config.py
# 配置数据迁移工具
cp alembic.ini.in alembic.ini
vi alembic.ini
# 这里主要配置数据库信息
sqlalchemy.url = postgresql://postgres:1q2w3e@localhost/paddles
# 触发迁移工具生效
alembic stamp head
```
到此为止，你已经完成了paddles需要的所有配置。当然，你现在还是处于沙盒环境之后，沙盒环境无非就是使用沙盒内的Python编译器执行你的命令而已，你甚至可以在./virtualenv/bin/中找到这些命令，有兴趣可以自行查看。
现在你需要启动你的paddles了，有两种情况。

 1. 为测试
    仅仅是为了看一下，我的paddles配置正确了吗，能够正常运行了吗，那么你可以通过在沙盒中运行
```shell
pecan serve config.py
```
直接临时启动你的paddles，然后就可以通过你在config.py中配置的地址来查看你的成果了，按照我的配置的话，打开浏览器，输入地址：
http://172.16.38.101:8080/
然后，你就会看到一串JSON格式的数据返回给你了。
应该是类似于：
```json
{"_help_": {"docs": "https://github.com/ceph/paddles", "extensions": {"Chrome": "https://chrome.google.com/webstore/detail/jsonview/chklaanhfefbnpoihckbnefhakgolnmc", "Firefox": "https://addons.mozilla.org/en-US/firefox/addon/jsonview/"}}, "last_job": "19 hours, 40 minutes, 22 seconds ago", "last_run": "21 hours, 1 minute, 28 seconds ago"}
```
这说明你的paddles已经可用了，它已经可以作为pulpito的存储后台来使用。
 2. 正式使用
    在install(1)中，我们已经说到要使用supervisord作为我们进程管理工具，这里我们将演示如何使用supervisord来管理我们的paddles。
（1）配置gunicorn
首先，我们要放弃使用pecan来运行我们的Python web服务，使用一个稍加封装的，更好的‘pecan’---- gunicorn，不必担心，你用不着重新安装它的环境，也一点都用不着去学，你只需要了解了解以下几个命令即可。
退到paddles用户环境，不退也可，都无所谓，只是编辑个文件而已
```shell
vi gunicorn_config.py
```
将该文件改为以下内容，甚至可能它原本就已经是以下内容了，那就不用改了
```python
import os
import multiprocessing
_home = os.environ[''HOME'']

workers = multiprocessing.cpu_count() * 2
workers = 10
max_requests = 10000
#loglevel = ''debug''
accesslog = os.path.join(_home, "paddles.access.log")
#errorlog = os.path.join(_home, "paddles.error.log")

```
然后你就可以退出该用户了，关于如何使用supervisord管理它，我们将在后面的章节中弹到，就在本章节下第2个章节，很快。

##pulpito的安装部署
特殊说明（1）：
https://github.com/caibo2014/gooreplacer4chrome
改Web应用设计到谷歌的API，最好使用谷歌浏览器进行访问，当然，如果你是位经验丰富的程序员，相信你也有别的方法来代替Google-front-api等。
后面会相信阐述该问题的解决方法。

特殊说明（2）：
我们建议将paddles和pulpito安装一台机器，使用不同的端口而已，因为这两个都是非常小而且不需要耗费太多资源的，也省去了安装很多依赖的问题

随着安装步骤的逐渐进行，前面已经提到的比较详细的简单步骤和操作技巧将一一被简化，相信你在阅读本文时也会渐渐适应这样的一种风格，简化后省去了你不必要的阅读量。

（1）安装依赖
和上面paddles需要的依赖是一样的，我们已经安装过了，这里不需要任何操作了。

（2）创建用户，并切换到对应的用户环境
```shell
useradd -m pulpito -g root -G root
echo pulpito:1q2w3e | chpasswd
su - pulpito
```
（3）克隆相应源码
```shell
git clone https://github.com/ceph/pulpito.git
```

（4）创建沙盒
```shell
virtualenv ./virtualenv
```
（5）编辑文件
```shell
cp config.py.in prod.py
vi prod.py
# 修改监听的地址和paddles的地址

server = {
    ''port'': ''8081'',
    ''host'': ''172.16.38.101''
}

paddles_address = ''http://172.16.38.101:8080''

# 同时，我们需要关闭掉pulpito的debug模式
''debug'': False,
```
（6）启动沙盒并安装依赖
```shell
source ./virtualenv/bin/activate
pip install -r requirements.txt
```
（7）启动pulpito
这个和上面的paddles一样，也分为两种情况。

 1. 为测试
```shell
   # 直接在沙盒内
   python run.py
```
然后打开浏览器，输入刚刚配置的监听地址：http://172.16.38.101:8081/
这个时候你应该能看到和http://pulpito.ceph.com/ 类似的界面，这说明你的pulpito也安装成功了。
 2. 正式使用
    正式使用把pulpito的运行线程交托给supervisord管理，下一章节讲解。

（8）关于打开界面非常慢，甚至卡住的情况
也就是前面特殊说明（1）提到的问题，这是由于该项目访问了谷歌的API的缘故，有经验的朋友直接查看本小节头给出的连接即可明白并解决问题了。
如果你没有处理过类似的情况，可直接将以下内容保存为:force_install_for_windows.reg
```dos
Windows Registry Editor Version 5.00

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Google\Chrome\ExtensionInstallForcelist]
"1"="paopmncpffekhhffcndhnmjincfplbma;https://github.com/jiacai2050/gooreplacer4chrome/raw/master/updates.xml"

[HKEY_LOCAL_MACHINE\SOFTWARE\Policies\Chromium\ExtensionInstallForcelist]
"1"="paopmncpffekhhffcndhnmjincfplbma;https://github.com/jiacai2050/gooreplacer4chrome/raw/master/updates.xml"

```
然后直接执行即可，本脚本也是来自于特殊说明（1）中的网址。

## supervisor的安装配置

（1）安装supervisor

这个和paddles还有pulpito都在一台机器上，其实我们前面安装依赖的时候，已经安装了supervisor了，如果你没有安装，再安装一次也可以。
```shell
# apt方式
apt-get install supervisor
# Python模块安装方式
pip install supervisor
```

（2）配置主文件
```shell
vi /etc/supervisor/supervisord.conf

# 该文件一般不需要配置，这里只是告诉你一下有这个文件，有什么疑问都可以去查看该文件

# 该文件规定了许多全局的配置，比如supervisord守护进程如何与supervisorctl控制台进行通信，如何将进程管理的UI通过HTTP发布等等。

# 如果你有一些特殊的需求，可以自行搜索百度supervisor，教程很多
```

（3）配置任务文件
正如主文件的默认的最后一行所说，它包含了一些其它的配置文件，我们称之为任务文件，它是用来描述一个任务的，也即supervisor应该监控哪些进程，执行哪些操作，都是在这些任务文件里面规定的。
这些文件都应该被放在supervisor默认规定的/etc/supervisor/conf.d目录下，想更改路径的话，可以在主配置文件中修改。
我们的两个任务文件分别被命名为：paddles.conf 和 pulpito.conf

paddles任务文件：
```shell
cat /etc/supervisor/conf.d/paddles.conf
```
```xml
[program:paddles]
user=paddles
environment=HOME="/home/paddles",USER="paddles"
directory=/home/paddles/paddles
command=/home/paddles/paddles/virtualenv/bin/gunicorn_pecan -c gunicorn_config.py config.py
autostart=true
autorestart=true
redirect_stderr=true
stdout_logfile = /home/paddles/paddles.out.log
stderr_logfile = /home/paddles/paddles.err.log

```

pulpito任务文件：
```shell
cat /etc/supervisor/conf.d/pulpito.conf
```
```xml
[program:pulpito]
user=pulpito
directory=/home/pulpito/pulpito
command=/home/pulpito/pulpito/virtualenv/bin/python run.py
environment=HOME="/home/pulpito",USER="pulpito"
autostart=true
autorestart=true
redirect_stderr=true
stdout_logfile = /home/pulpito/pulpito.out.log
stderr_logfile = /home/pulpito/pulpito.err.log

```

两个配置文件都比较简单，其中的command选项即我们跑这个守护线程时，守护线程需要干的事情，我们看到，其实我们配置的这两个守护线程无非也就是用我们刚才创建的沙盒环境来执行特定的命令而已，只不过我们刚才是手工做，现在交给supervisor来做。

（3）使用supervisor启动任务
```shell
# 通过supervisorctl控制台启动
supervisorctl start all
# 你也可以通过supervisord本身启动
# supervisord -c /etc/supervisor/supervisord.conf

# 启动之后你可以查看下这两个进程的状态
supervisorctl status

# 应该看到以下结果
root@client1:/etc/supervisor/conf.d# supervisorctl status
paddles                 RUNNING    pid 4872, uptime 2 days, 22:10:20
pulpito                 RUNNING    pid 4873, uptime 2 days, 22:10:20

```
到这里你已经成功使用supervisor来管理你的paddles和pulpito，你不用再担心因为重启而引发paddles或者pulpito不可用，supervisor会随时监测这两个线程的状态，一旦重现问题，它就会尝试重启它们。


## gitbuilder的搭建和使用
官方教程：https://github.com/ceph/gitbuilder

gitbuilder也可以说就是个apt-get的源，请参看：
http://gitbuilder.ceph.com/
这是ceph官方搭建好的gitbuilder。
gitbuilder相对来说没什么好搭建的，只是讲讲怎么使用它。
首先找一台性能比较好的机器，单独的用来做gitbuilder，物理机或者虚拟机都可以，但是性能请尽量好一点，不然你每编译一次，可能就要你一下午的时间。

（1）克隆项目源码
```shell
git clone https://github.com/ceph/gitbuilder.git
# 同样的，你需要做许多的更改以适应编译你自己的ceph
# 你可以克隆我们更改过的，这样你只需要稍作修改即可
# git clone https://github.com/H3C/gitbuilder.git
# 当然，我们还是会全面的讲一下修改的地方
```

（2）获取我们需要编译的代码
其实这个gitbuilder可以用于编译任何项目的，是个通用的框架。我们这里用它来编译ceph，所以我们需要获取我们的ceph代码
```shell
# 进入到目录中，gitbuilder只负责编译目录为build下的那些代码
# 所以我们把我们的ceph代码克隆到build文件夹下
cd gitbuilder
git clone https://github.com/H3C/ceph.git build
```
（3）修改分支脚本，只编译我们想要编译的分支
gitbuilder中有一个脚本文件是用来控制你需要编译的分支的，名为：branches.sh
我们可以对它稍加修改，只关注我们自己的分支，我这里使用的是比较粗暴的方法
```shell
# 在执行任何git指令之前，强行输出我想编译的那几个分支，然后直接退出
# 比如我只想编译分支“master”
echo "master"
exit 0
.
.
.
# 其实branches.sh里本身就提供了分支控制的语句
 if [ -x ../branches-local ]; then
     exec ../branches-local "$@"
 fi
# 这里它执行的这句话就是如果存在这个脚本就直接执行了，你也可以将你想要编译的分支写到这个脚本里。
方法很多，这些更改其实都是在autobuilder.sh中有调用到。
```

（4）修改build.sh
```shell
cp build.sh.example build.sh
vi build.sh
# 其实里面默认的那些语句对编译ceph都没什么用，可直接删除或注释
# 将build.sh的内容改为:
cp ../make-debs.sh .
chmod 777 make-debs.sh
./make-debs.sh /ceph_tmp/release
```

（5）创建make-debs.sh
上面我们拷贝了一份make-debs.sh到我们的ceph目录下并进行执行，那么这个make-debs.sh从哪里来呢，该文件存于ceph项目的根目录中。

```shell
# 我们可以直接用ceph自身提供的make-debs.sh来进行编译
# 该脚本位于ceph项目的根目录
# 你可以到ceph中去拷贝一份，然后稍作修改即可
```
这里我使用github的展现方式来表明要修改的地方，主要修改也就是增加了编译时的线程，去除打包到debian中的代码，以及添加一个version文件。
```github
diff --git a/make-debs.sh b/make-debs.sh
index b8d3e46..529af65 100755
--- a/make-debs.sh
+++ b/make-debs.sh
@@ -58,8 +58,8 @@ tar -C $releasedir -zxf $releasedir/ceph_$vers.orig.tar.gz
 #
 cp -a debian $releasedir/ceph-$vers/debian
 cd $releasedir
-perl -ni -e ''print if(!(/^Package: .*-dbg$/../^$/))'' ceph-$vers/debian/control
-perl -pi -e ''s/--dbg-package.*//'' ceph-$vers/debian/rules
+#perl -ni -e ''print if(!(/^Package: .*-dbg$/../^$/))'' ceph-$vers/debian/control
+#perl -pi -e ''s/--dbg-package.*//'' ceph-$vers/debian/rules
 #
 # always set the debian version to 1 which is ok because the debian
 # directory is included in the sources and the upstream version will
@@ -80,11 +80,7 @@ fi
 # b) do not sign the packages
 # c) use half of the available processors
 #
-: ${NPROC:=$(($(nproc) / 2))}
-if test $NPROC -gt 1 ; then
-    j=-j${NPROC}
-fi
-PATH=/usr/lib/ccache:$PATH dpkg-buildpackage $j -uc -us
+PATH=/usr/lib/ccache:$PATH dpkg-buildpackage -j120 -uc -us
 cd ../..
 mkdir -p $codename/conf
 cat > $codename/conf/distributions <<EOF
@@ -94,6 +90,7 @@ Components: main
 Architectures: i386 amd64 source
 EOF
 ln -s $codename/conf conf
+echo $dvers > version
 reprepro --basedir $(pwd) include $codename WORKDIR/*.changes
 #
 # teuthology needs the version in the version file
```

（6）修改autobuilder.sh
这个脚本文件才是整个builder真正的入口，前面的一切准备工作，最后都是被脚本所调用，稍有shell基础的朋友看下这个脚本就能明白整个项目的运作方式了。

我们这里对这个脚本稍作修改，以便它能够正确的将我们的编译好的deb包，放到正确的目录，方便我们后续通过web服务器将它发布出去。
同样使用github的风格展示
```github
+++ autobuilder.sh      2015-07-02 10:59:09.588364316 +0800
@@ -54,6 +54,12 @@
                trap "echo ''Killing (SIGINT)'';  kill -TERM -$XPID; exit 1" SIGINT
                trap "echo ''Killing (SIGTERM)''; kill -TERM -$XPID; exit 1" SIGTERM
                wait; wait
+               mkdir -p /ceph_repos/ceph-deb-trusty-x86_64-basic/ref/${branch#*/}
+               cp -r --preserve=links /ceph_tmp/release/Ubuntu/{conf,db,dists,pool,trusty,version} /ceph_repos/ceph-deb-trusty-x86_64-basic/ref/${branch#*/}
+               echo $ref > /ceph_repos/ceph-deb-trusty-x86_64-basic/ref/${branch#*/}/sha1
+
+               mkdir -p /ceph_repos/ceph-deb-trusty-x86_64-basic/sha1/
+               ln -s /ceph_repos/ceph-deb-trusty-x86_64-basic/ref/${branch#*/} /ceph_repos/ceph-deb-trusty-x86_64-basic/sha1/$ref
+               rm -rf /ceph_tmp/release/*
        done
```

（7）运行
所有准备都完成了之后，我们要开始编译我们的项目了，直接运行
```shell
./start
```
其实该脚本就是运行了autobuilder.sh和一个文件锁操作

（8）如何了解直接的编译结果
所有的编译结果都会输出到当前目录的out文件夹下，这里面输出的其实是cgi文件，可以理解为较为高级、通用的网页文件，既然是网页文件，这个时候你就需要一个服务器来展示这些网页文件了。
建议你使用apache2。这个服务器安装极其方便，安装后通过简单的配置即可使其支持cgi文件。

1）安装apache2服务器
```shell
apt-get install apache2
```
2） 创建一个配置文件以支持cgi程序
```shell
vi /etc/apache2/mods-enabled/cgi.load

LoadModule cgi_module /usr/lib/apache2/modules/mod_cgi.so
AddHandler cgi-script .cgi .pl .py .sh

<Directory /var/www/html/gitbuilder>
Options +Indexes +FollowSymLinks +MultiViews +ExecCGI
AllowOverride None
Order allow,deny
allow from all
</Directory>
```
3）链接文件到/var/www/html下
apache2服务器默认的服务地址是/var/www/html文件夹下，为了更好使其能够展示我们的编译结果，我们做一个软连接到该目录下
```shell
ln -s "out文件夹对应的地址"/out /var/www/html/gitbuilder
```
4）解决权限问题
将out文件所在的目录以及父目录都赋权，比如我的存在家目录下~/repo
```shell
chmod 777 ~/repo -R
# 如果你不想以后都有这个麻烦，直接将家目录更改下权限
# chmod 777 ~ -R
# 都是内网环境，也不存在明显的安全问题
```
5）启动服务器并验证
```shell
service apache2 restart
```
打开浏览器，输入相应的地址：
http://gitbuilder-host-IP/gitbuilder
即可看到本次编译完成的情况
其实感觉根本没必要这么看，因为在编译的时候，是会输出到屏幕的，大概就能知道哪些成功或者失败了，或者从最后打包的情况，也能看出来。

6）做成apt-get源
  这一步才是我们真正的目的，编译完成了之后，结果是一大堆的deb包和很多的包信息文件，我们现在要做的就是将其发布到网上。
我们这里选择的服务器是nginx，这是为了方便我们以后做反向代理，多台机器进行编译时，发布地址可能不在一台服务器上，所以我个人感觉nginx是最好的选择，当然，这只是建议，具体什么服务器，由你自己选择，本文对如何使用nginx来完成这一任务，做一定的描述。

根据前面我们的配置，所有的deb包最后都拷贝到了/ceph_repos下
所以我们要做的事情很简单，就是将/ceph_repos这个目录发布出去，发布的时候带有目录结构方便在网络上查看。

以下前两个步骤，如果你直接使用apt-get install nginx的话就不需要了，可直接跳过查看如何配置nginx

 1） 下载nginx源码
```shell
# 下载的话直接搜索下nginx download就有了
# 解压nginx包，本文使用的是1.80
tar xzvf nginx-1.8.0.tar.gz
# 安装nginx依赖
apt-get install libpcre3 libpcre3-dev zlibc openssl libssl-dev libssl0.9.8
```
2）编译并安装nginx
```shell
./configure
make && make install
```
然后你需要配置一下环境变量
```shell
vi ~/.bashrc

# 添加一行
export PATH=$PATH:/usr/local/nginx/sbin

# 然后使更改立刻生效
source ~/.bashrc
```
 - 配置nginx.conf
这是nginx的配置文件，如果是apt-get的方式安装的话，好像在/etc/nginx下，如果是源码安装的话则在/usr/local/nginx/conf下
```shell
vi /usr/local/nginx/conf/nginx.conf
```
主要改两个地方：
 - 配置nginx使其默认的文件类型为text/plain
   这样就不会碰到没有类型的文件就直接下载了
```shell
default_type  text/plain;
```
 - 配置nginx服务器的根路径
   使用户直接访问本机IP时，可以跳转到/ceph_repos下。
```shell
    location / {
        # 打开目录控制，使我们的页面能以目录方式呈现给用户
        autoindex on;
        root   /ceph_repos;
    }

```
3）启动nginx并验证
```shell
# 启动nginx
nginx
# 停止nginx
nginx -s stop
# apt-get的方式
service nginx start|restart|stop
```
然后打开对应的网址如：http://172.16.38.102
你就可以看到类似于：http://gitbuilder.ceph.com/的效果了。

## NTP服务器安装配置
这个非常的简单，按照本文的风格，类似的小组件，我们只是简单的介绍一两个，由于这些小组件都十分的通用，大家在看到的时候可直接通过网络搜索教程即可。
```shell
apt-get install ntp

vi /etc/ntp.conf

# 规定哪些IP能访问本服务器
restrict 172.16.100.0 mask 255.255.0.0 nomodify
server 127.127.1.0
fudge 127.127.1.0 stratum 10
```
顺利完成0，重启下NTP就好，十分的方便
```shell
service ntp restart
```

## teuthology任务执行节点的安装
在本文中，一直称之为slave节点，这比较类似于Hadoop中的分级，master节点负责管理信息，然后布置任务给slave节点，slave节点负责完成这些任务，然后把结果信息反馈给master节点。

teuthology的slave节点，也称之为任务资源，其实就是一台台的装有Ubuntu系统的虚拟机，当然也可以是物理机，但是我们不建议那么做。

1）安装一台虚拟机
   我们安装的是Ubuntu14.0LTS，也建议你使用该系统
2）配置可远程ssh登录
   相信你前面的机器也是通过类似CRT，Xshell的工具登录并操作的，那么应该也已经知道如何配置了，这里再重提一下。
```shell
vi /etc/ssh/sshd_config
# 更改为下面行
PermitRootLogin yes
service ssh restart
```
3）安装ansible
```shell
apt-get install ansible
```
4）安装配置NTP
```shell
apt-get install ntp
# 并修改配置文件使其执行前面配置的NTP server
vi /etc/ntp.conf
# 注释掉那些原有的server，添加我们自己的
server "前面配置的NTP Server地址"
```
5）添加名为''ubuntu''的用户
此处只能添加名字为ubuntu的用户，添加其它名字都是不行，这也是teuthology这个平台不够完善的表现。
```shell
useradd ubuntu –m –G root –g root -s /bin/bash
echo ubuntu:1q2w3e | chpasswd
```
6）配置免密使用sudo命令
```shell
vi /etc/sudoers
# 添加行
ubuntu   ALL=(ALL)         NOPASSWD: ALL

```
7）情况apt-get源
```shell
mv /etc/apt/sources.list  /etc/apt/sources.list.bak
touch /etc/apt/sources.list
```
8）安装ceph相关依赖
该问题较为复杂，你可以通过尝试使用之前我们搭建的gitbuilder作为apt-get源，然后试着安装一下ceph，系统就会告诉你缺少哪些依赖，然后你需要去把这些依赖都下载下来并安装上，如果你连接着网络，这些依赖都可以通过apt-get的方式来安装，还是比较方便的

9）hostname和hosts匹配
由于ansible是一个去中心化工具，所以所有slave节点都可能要互相交互，所以但是teuthology传递给他们的是一个hostname而不是具体的IP，所以hosts文件就起到了转换这些hostname的作用，两个点注意。

 - 自己的hostname，请与127.0.1.1相对应
 - 其它人的hostname,所有节点请保持统一

10）防止pgp认证错误
apt-get pgp error，如果完全不了解的话可以先搜索下前面的关键字。

将你搭建的gitbuilder作为源，然后apt-get update，如果出现了apt-get pgp error错误的话则需要你手工处理一下。

处理方式也很简单，报错时它会提示给你一串数字，将这串数字注册一下就好。
```shell
apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 6EAEAE2203C3951A
```

到此一个teuthology的slave节点就安装完毕了，然后你就可以通过虚拟机的各种克隆技术疯狂的克隆了，克隆30台左右就好，当然如果你是物理机的话那就没办法了，这也是我们不建议你使用物理机的原因之一。


## teuthology管理节点的部署

我们先讲teuthology主体的安装，而不先说git server等组件的安装时因为在安装完前面的组件之后，已经能够支撑teuthology运行一定的任务，所以我先讲如何安装teuthology，让大家快速的部署好环境并尝试着运行一些任务。

我们建议安装teuthology的机器应该是磁盘容量较大的，至少请在500G以上，当然20G的也可以运行，但是teuthology跑一次任务产生的日志文件大小可能就有20G，磁盘空间满了之后，你的任务将无法继续进行。

前面我们已经说过，随着安装的进行，我们对于一些小细节的描述将省去，比如这里安装各类依赖，势必要先配置好apt-get的源，经过前面的磨练，这样的步骤你已经非常熟练，这里就不再重复写出来浪费文章篇幅了。

###系统环境配置
1）安装系统依赖
```shell
apt-get -y install git python-dev python-pip python-virtualenv libevent-dev python-libvirt beanstalkd
```
其中beanstalkd为teuthology所使用的任务队列组件，大家可以自行搜索下。

2）为调度者和执行者创建账号
不清楚调度者和执行者区别请参见install（1）
```shell
useradd -m teuthology -g root -G root
echo teuthology:1q2w3e | chpasswd

useradd -m teuthworker -g root -G root
echo teuthworker:1q2w3e | chpasswd

```

3）分别给两个账号授予passwordless sudo access权限
```shell
vi /etc/sudoers

# 添加下面两行

teuthology   ALL=(ALL)         NOPASSWD: ALL
teuthworker  ALL=(ALL)         NOPASSWD: ALL

```

4）创建配置文件
```shell
vi /etc/teuthology.yaml

# 内容如下（部分请自行修改）：

# paddles所在服务器
lock_server: ''http://172.16.38.101:8080''
# paddles所在服务器
results_server: ''http://172.16.38.101:8080''
# 域名，创建slave节点时有用到
lab_domain: ''h3c-ceph.com''
# beanstalkd队列服务器，第一步安装的，就在我们本地，默认端口是11300
queue_host: 127.0.0.1
queue_port: 11300
# 本地归档，直接放在执行者的家目录下
archive_base: /home/teuthworker/archive
verify_host_keys: false
# 官方的是：http://github.com/ceph/，就是我们下载各种需要的组件源码的路径
# 这里暂时使用github上的，之后我们将搭建一个完整的git服务器替代它
ceph_git_base_url: http://github.com/H3C/
# 就是前面搭的gitbuilder的地址
gitbuilder_host: ''172.16.38.102''
reserve_machines: 1
# 归档目录，直接写本机的地址加/teuthology即可
archive_server: http://172.16.38.103/teuthology/
max_job_time: 86400

```

5）安装其它依赖
这些依赖并不是在系统级别上使用，而是各个用户在执行命令时需要使用到
```shell
apt-get -y install git python-dev python-pip python-virtualenv libevent-dev python-libvirt beanstalkd
```
开发相关依赖
```shell
apt-get -y install  libssl-dev libmysqlclient-dev libffi-dev libyaml-dev
```

###安装调度者

我们已经为调度者创建了一个用户teuthology，接下来的操作都在teuthology中进行。
```shell
su - teuthology
```

1）克隆代码并初始化环境
```shell
mkdir ~/src

# 你也克隆我们的,做了一些修改，比如可以关闭每次都去网上拉取这样的特性
# 更多的信息你可以通过查看我们的github地址来寻找
# git clone https://github.com/H3C/teuthology.git src/teuthology_master
git clone https://github.com/ceph/teuthology.git src/teuthology_master

# 进入到克隆好目录下并执行脚本 bootstrap
./bootstrap

# 该脚本为初始化各类环境的脚本，它会从网上去下载很多组件和脚本
# 一般来说，这个脚本是不会出错的
```

2）创建slave节点
这里的意思其实就是将一些我们已经安装好的slave节点的信息采集起来，然后传输给paddles，这样我们就知道一共有多少台可以利用的资源了，跑任务的时候就可以去用这些资源。

收集这些节点信息并最终存到数据库，对我们来说只要做一件事就好，那就是编辑create_nodes.py这个脚本，改动非常的小。

首先要做的就是获取这个脚本：
```shell
wget https://raw.githubusercontent.com/ceph/teuthology/master/docs/_static/create_nodes.py
```
因为这完全就是一个网络脚本，为了防止它不断的变化而导致本文的可用性，这里提供一下当时我们使用的脚本，如果没有更新话，你应该下载到和我一样的一个脚本。
我们将需要更改的地方也在文中标明了，只需要更改前面几行即可。

```python
#!/usr/bin/env python
# A sample script that can be used while setting up a new teuthology lab
# This script will connect to the machines in your lab, and populate a
# paddles instance with their information.
#
# You WILL need to modify it.

import traceback
import logging
import sys
from teuthology.orchestra.remote import Remote
from teuthology.lock import update_inventory

# 这里改为你的paddles地址，这是本文一直使用的paddles地址
paddles_address = ''http://172.16.38.101:8080''

# 你想创建的机器类型，也就是为你的slave节点分个类
# 什么类型名字其实无所谓，但等会你执行任务时默认为plana
# 指定为plana类型，运行任务时可以省去指定机器类型语句
# 建议你以plana, buripa, miraas作为类型名，方便和官方统一
machine_type = ''plana''
# 前面我们配置/etc/teuthology.yaml文件时已经指定了域名，相同就行
lab_domain = ''h3c-ceph.com''
# Don''t change the user. It won''t work at this time.
user = ''ubuntu''
# We are populating ''typica003'' -> ''typica192''
# 这里更改一下编号，从哪一号到哪一号
# 这是需要修改的最后一行，后面都不需要修改了
machine_index_range = range(17, 22)

log = logging.getLogger(sys.argv[0])
logging.getLogger("requests.packages.urllib3.connectionpool").setLevel(
    logging.WARNING)


def get_shortname(machine_type, index):
    """
    Given a number, return a hostname. Example:
        get_shortname(''magna'', 3) = ''magna003''

    Modify to suit your needs.
    """
    return machine_type + str(index).rjust(3, ''0'')


def get_info(user, fqdn):
    remote = Remote(''@''.join((user, fqdn)))
    return remote.inventory_info


def main():
    shortnames = [get_shortname(machine_type, i) for i in machine_index_range]
    fqdns = [''.''.join((name, lab_domain)) for name in shortnames]
    for fqdn in fqdns:
        log.info("Creating %s", fqdn)
        base_info = dict(
            name=fqdn,
            locked=True,
            locked_by=''admin@setup'',
            machine_type=machine_type,
            description="Initial node creation",
        )
        try:
            info = get_info(user, fqdn)
            #log.error("no error happened")
            base_info.update(info)
            base_info[''up''] = True
        except Exception as exc:
            log.error("{fqdn} is down".format(fqdn=fqdn))
            #log.error("some error: {0}".format(exc.strerror))
            log.error("the traceback is")
            s=traceback.format_exc()
            log.error(s)
            log.error("the error is ")
            log.error(exc)
            base_info[''up''] = False
            base_info[''description''] = repr(exc)
        update_inventory(base_info)
if __name__ == ''__main__'':
    main()

```

修改完成之后，把这个文件放到我们克隆的~/src/teuthology_master中，或者你刚才wget时直接放到该路径下也可以，之后执行以下该脚本即可。
```shell
python create_nodes.py
```
你一定很好奇，这些名字既然是随便取的，那么如何定位这些机器的IP呢，这其实是需要你在/etc/hosts文件中指定的，这也是teuthology平台的特性，都只是给出hostname，具体IP都是由hosts文件给出。

前面配置之后，产生的hostname的组成结构是：
```shell
machine_type + 3位数字 + ''.'' + lab_domain
```
比如我的机器类型为''plana''，正好是集群中的第3台机器，我的域名规定为h3c-ceph.com，那么最终产生的hostname是：
```shell
plana003.h3c-ceph.com
```
这时我就需要在/etc/hosts文件中为其指定对应的IP
```shell
plana003.h3c-ceph.com  172.16.38.143
```

3）验证是否已成功上传了slave节点信息
检验方式很简单，登录我们之前搭建的pulpito界面，点击右上方的node，选择ALL，即可查看我们当前拥有的所有的资源节点，如果有的话则代表你已经成功推送slave节点信息到数据库中了。

简单的看下各个节点的信息，你会发现所有节点都是处于锁住状态的，你可以通过类似于：
```shell
teuthology-lock --owner caibo --unlock plana003
```
的命令来进行解锁，在install（3）中，我们将学习更多的命令来帮助管理者这些资源节点，调度任务，管理执行者，查看任务队列等。

当然，执行该命令的前提是teuthology的执行目录已经被你加载到环境变量中了
```shell
echo ''PATH="$HOME/src/teuthology_master/virtualenv/bin:$PATH"'' >> ~/.profile
# 即刻生效
source ~/.profile
```

###安装执行者
执行者的安装相对简单

切换到teuthworker用户下

1）克隆源码并初始化环境
```shell
mkdir ~/src
git clone https://github.com/H3C/teuthology.git src/teuthology_master
cd ~/src/teuthology_master
./bootstrap
```

2）初始化执行环境
```shell
mkdir ~/bin
# 从网上下载该脚本
wget -O ~/bin/worker_start https://raw.githubusercontent.com/ceph/teuthology/master/docs/_static/worker_start.sh
```
出于同样的目的，我们还是向大家展示下我们获取到的脚本，以免脚本更新引起的误会

```shell

#!/bin/bash

# A simple script used by Red Hat to start teuthology-worker processes.

ARCHIVE=$HOME/archive
WORKER_LOGS=$ARCHIVE/worker_logs

function start_workers_for_tube {
    echo "Starting $2 workers for $1"
    for i in `seq 1 $2`
    do
        teuthology-worker -v --archive-dir $ARCHIVE --tube $1 --log-dir $WORKER_LOGS &
    done
}

function start_all {
    start_workers_for_tube plana 50
    start_workers_for_tube mira 50
    start_workers_for_tube vps 80
    start_workers_for_tube burnupi 10
    start_workers_for_tube tala 5
    start_workers_for_tube saya 10
    start_workers_for_tube multi 100
}

function main {
    echo "$@"
    if [[ -z "$@" ]]
    then
        start_all
    elif [ ! -z "$2" ] && [ "$2" -gt "0" ]
    then
        start_workers_for_tube $1 $2
    else
        echo "usage: $0 [tube_name number_of_workers]" >&2
        exit 1
    fi
}

main $@

```
这个脚本比较简单，就是调用了teuthology-worker而已。

3）配置环境变量
```shell
echo ''PATH="$HOME/src/teuthology_master/virtualenv/bin:$PATH"'' >> ~/.profile

source ~/.profile

# ！！！你需要创建一个目录，不然执行启动时会报错
mkdir -p ~/archive/worker_logs
# 如果你是挂载的话，你还需要将这个目录的权限赋一下
```
现在你可以使用teuthology的命令了
尝试启动一个执行plana类型任务的执行者
```shell
worker_start plana 1
```
你会看到屏幕上有一些输出，说明已经开始在后台运行了，如果不幸出现错误，你可以根据具体的错误的信息进行解决，无非就是网络问题，权限问题。

你可以通过
```shell
killall -u teuthworker
```
来终结teuthworker用户拥有的所有进程

接下来你可以直接看install（3）来进行一些最基本的命令尝试，感受一下teuthology的运行和命令方式。
其实真正的想搭建好teuthology平台还是在于尝试，尝试各种命令，解读安装过程中的报错，分析执行日志中的报错，这样才能更好的掌控它。

##git server的搭建和使用
到了这里，我认为已经属于对teuthology由来初步的了解了，现在你应该知道teuthology的任何和运行方式其实是定义在许许多多的yaml文件中的，这些yaml文件定义了如何去执行任务。
在teuthology的管理节点上，启动执行者之前会尝试从网络上拉取一些代码，执行过程中，管理节点也会尝试拉取一些代码，这个比较容易解决，或者给这一台机器连上网络，使其能够上网拉取代码，或者按照我们的方式，稍微对其代码做一定的修改，则可以避免这样的情况。具体的修改可以参看我们的项目，前面已经多次提到：https://github.com/H3C/teuthology

但是对于在任务执行过程中，teuthology slave节点也会上网拉取信息，这个我们却没有特别好的办法，首先，这个从何处拉取代码是有ceph-qa-suite决定的，所以想要在执行过程中纯粹使用内网，首先就需要修改ceph-qa-suite，如何修改可以参考：https://github.com/H3C/ceph-qa-suite
修改了ceph-qa-suite之后能够解决一部分的上网问题，拉取qa的动作就会从你指定的git地址拉取，但是比较可怕的是，这许多的测试例中，有很多脚本和源码需要从你在/etc/teuthology.yaml中指定的ceph_git_base_url。

安装相关软件
```shell
# 安装git
apt-get install git git-core

# 安装git-deamon
apt-get install git-daemon-run
```
```shell
# 编辑配置文件
vi /etc/service/git-daemon/run
```

```shell
cat /etc/service/git-daemon/run

#!/bin/sh
exec 2>&1
echo ''git-daemon starting.''
exec chpst -ugitdaemon \
  "$(git --exec-path)"/git-daemon --verbose --export-all --reuseaddr \
    --enable=receive-pack  --base-path=/git/
```
裸克隆代码到指定的目录
```shell
# git clone http://172.16.100.2/gerrit/ceph.git ceph.git
git clone https://github.com/H3C/ceph.git ceph.git

cd ceph.git
# 修改配置文件，开放各类权限
# 如果不是裸仓库的话，应该默认都开放的，就无需配置了
vi config
```
```shell
cat config

[core]
        repositoryformatversion = 0
        filemode = true
        bare = true
[remote "origin"]
        url = https://github.com/H3C/ceph.git
        fetch = +refs/*:refs/*
        mirror = true

[daemon]
        uploadpack = true
        uploadarch = true
        receivepack = true
        allowunreachable = true
```



```shell
# 启停命令
sv down git-daemon
sv up git-daemon
```


##smtp邮件服务器

这可以在teuthology的源码做一些简单的修改

```
smtpserver = config.smtpServer or ''localhost''
smtpuser = config.smtpUser
smtpasswd = config.smtpPasswd
smtp = smtplib.SMTP(smtpserver)
if smtpuser is not None and smtpasswd is not None:
    smtp.login(smtpuser, smtpasswd)
```

或者自己在teuthology的主机上搭一个本地的smtp服务器

##git web
git http-backend
或者
gitweb

##pip服务器
由于在某些测试例中，如s3需要使用pip install安装软件，如果此时想保持在内网环境，则需要搭建一个pip服务器

###安装pip2pi工具
```
pip install pip2pi
```
或:
```
git clone https://github.com/wolever/pip2pi
cd pip2pi
python setup.py install
```

###创建存放软件包的仓库
```
mkdir /root/pypi
```
/root下创建requirement.txt，并且将所有你需要的包放到requirement.txt里面

###下载软件包并建立索引
```
pip2tgz  /root/pypi  -r list/requirements.txt

# 建立索引
# 保证在simple下面能有所有自己需要的包
dir2pi   /root/pypi

```

###测试
```
pip install –i 你的IP地址:端口/simple
```

##DNS服务器
由于teuthology和ceph-qa中都存在许多测试用例是需要去上网的，但是如果纯粹通过修改代码来实现重定向到自己的服务器的话，是比较繁琐的，而且也无法保证后续与社区同步
```shell
vi /etc/bind/named.conf.default-zones

zone "radosgw.h3c.com" {
        type master;
        file "/etc/bind/db.200";
};

```
radosgw.h3c.com为自己定义的域名
db.200为自定义文件名

```shell
vi db.200

$TTL 604800
@       IN      SOA     radosgw.h3c.com.        root.radosgw.h3c.com.(
                                1 ; Serial
                                604800 ; Refresh
                                86400 ; Retry
                                2419200 ; Expire
                                604800 ) ; Negative Cache TTL
;
@               IN      NS      localhost.
@               IN      A       172.16.51.6
*             IN      A       172.16.51.6

```

172.16.51.6为该主机的IP
```shell
vi /etc/resolv.conf
# 将DNS服务器改为主机IP
nameserver 172.16.51.6
```

```shell
# 重启DNS服务
service bind9 restart
# curl+自己域名验证能否被解析
curl radosgw.h3c.com
```

##git web
http://serverfault.com/questions/72732/how-to-set-up-gitweb




','蔡博','2017-08-28 22:39:02',0);
