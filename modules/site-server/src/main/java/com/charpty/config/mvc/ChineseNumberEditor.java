package com.charpty.config.mvc;

import com.tomato.util.NumberUtil;
import org.springframework.beans.propertyeditors.CustomNumberEditor;

import java.math.BigDecimal;
import java.text.DecimalFormat;

public class ChineseNumberEditor extends CustomNumberEditor {
	private static final int POOR_SCALE_MIN = NumberUtil.POOR_SCALE_MIN;

	/**
	 * @param numberClass
	 * @param allowEmpty
	 *
	 * @throws IllegalArgumentException
	 */
	public ChineseNumberEditor(Class<? extends Number> numberClass, boolean allowEmpty) throws IllegalArgumentException {
		super(numberClass, getChineseDecimalFormat(), allowEmpty);
	}

	/**
	 * @return
	 */
	protected static DecimalFormat getChineseDecimalFormat() {
		DecimalFormat decimalFormat = new DecimalFormat();
		decimalFormat.setMaximumFractionDigits(340);
		return decimalFormat;
	}

	/* (non-Javadoc)
	 * @see org.springframework.beans.propertyeditors.CustomNumberEditor#setAsText(java.lang.String)
	 */
	@Override
	public void setAsText(String text) throws IllegalArgumentException {
		super.setAsText(text);
		Object value = getValue();
		if (value instanceof BigDecimal) {
			BigDecimal bigDecimal = (BigDecimal) value;
			int scale = bigDecimal.scale();
			if (scale < 0 && scale > POOR_SCALE_MIN) {
				super.setValue(bigDecimal.setScale(0, BigDecimal.ROUND_UNNECESSARY));
			}
		}
	}

	/* (non-Javadoc)
	 * @see org.springframework.beans.propertyeditors.CustomNumberEditor#setValue(java.lang.Object)
	 */
	@Override
	public void setValue(Object value) {
		if (value instanceof BigDecimal) {
			BigDecimal bigDecimal = (BigDecimal) value;
			int scale = bigDecimal.scale();
			if (scale < 0 && scale > POOR_SCALE_MIN) {
				value = bigDecimal.setScale(0, BigDecimal.ROUND_UNNECESSARY);
			}
		}
		super.setValue(value);
	}

}
