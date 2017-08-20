package com.charpty.config.mvc;

import org.springframework.beans.propertyeditors.CustomDateEditor;
import org.springframework.web.bind.WebDataBinder;
import org.springframework.web.bind.support.ConfigurableWebBindingInitializer;
import org.springframework.web.context.request.WebRequest;
import org.springframework.web.multipart.support.ByteArrayMultipartFileEditor;

import java.math.BigDecimal;
import java.text.SimpleDateFormat;
import java.util.Date;

public class AppWebBindingInitializer extends ConfigurableWebBindingInitializer {

	/* (non-Javadoc)
	 * @see org.springframework.web.bind.support.WebBindingInitializer#initBinder(org.springframework.web.bind.WebDataBinder, org.springframework.web.context.request.WebRequest)
	 */
	@Override
	public void initBinder(WebDataBinder binder, WebRequest request) {
		super.initBinder(binder, request);
		/**
		 * @see org.springframework.beans.PropertyEditorRegistrySupport
		 */
		// TODO 发现每次 ServletRequest 调用时，多个参数均会调用一次本方法，因此以下方法在此设置并非最佳！
		binder.registerCustomEditor(BigDecimal.class, new ChineseNumberEditor(BigDecimal.class, true));
		// Use the ByteArrayMultipartFileEditor for converting MultipartFiles to byte arrays.
		binder.registerCustomEditor(byte[].class, new ByteArrayMultipartFileEditor());
		// Date
		SimpleDateFormat dateFormat = new SimpleDateFormat("yyyy-MM-dd");
		dateFormat.setLenient(false);
		binder.registerCustomEditor(Date.class, new CustomDateEditor(dateFormat, true));
	}

}
