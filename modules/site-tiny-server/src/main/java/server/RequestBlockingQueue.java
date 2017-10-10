package server;

import java.util.Collection;
import java.util.Iterator;
import java.util.concurrent.BlockingQueue;
import java.util.concurrent.TimeUnit;

/**
 * @author caibo
 * @version $Id$
 * @since 2017/10/10 下午9:16
 */
public class RequestBlockingQueue implements BlockingQueue {
	public boolean add(Object o) {
		return false;
	}

	public boolean offer(Object o) {
		return false;
	}

	public Object remove() {
		return null;
	}

	public Object poll() {
		return null;
	}

	public Object element() {
		return null;
	}

	public Object peek() {
		return null;
	}

	public void put(Object o) throws InterruptedException {

	}

	public boolean offer(Object o, long timeout, TimeUnit unit) throws InterruptedException {
		return false;
	}

	public Object take() throws InterruptedException {
		return null;
	}

	public Object poll(long timeout, TimeUnit unit) throws InterruptedException {
		return null;
	}

	public int remainingCapacity() {
		return 0;
	}

	public boolean remove(Object o) {
		return false;
	}

	public boolean addAll(Collection c) {
		return false;
	}

	public void clear() {

	}

	public boolean retainAll(Collection c) {
		return false;
	}

	public boolean removeAll(Collection c) {
		return false;
	}

	public boolean containsAll(Collection c) {
		return false;
	}

	public int size() {
		return 0;
	}

	public boolean isEmpty() {
		return false;
	}

	public boolean contains(Object o) {
		return false;
	}

	public Iterator iterator() {
		return null;
	}

	public Object[] toArray() {
		return new Object[0];
	}

	public Object[] toArray(Object[] a) {
		return new Object[0];
	}

	public int drainTo(Collection c) {
		return 0;
	}

	public int drainTo(Collection c, int maxElements) {
		return 0;
	}
}
