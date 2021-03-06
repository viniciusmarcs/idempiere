CREATE OR REPLACE FUNCTION BOMPRICELIMIT
(
	Product_ID 		IN NUMBER,
	PriceList_Version_ID	IN NUMBER
)
RETURN NUMBER
/*************************************************************************
 * The contents of this file are subject to the Compiere License.  You may
 * obtain a copy of the License at    http://www.compiere.org/license.html
 * Software is on an  "AS IS" basis,  WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for details. Code: Compiere ERP+CRM
 * Copyright (C) 1999-2002 Jorg Janke, ComPiere, Inc. All Rights Reserved.
 *************************************************************************
 * $Id: BOM_PriceLimit.sql,v 1.1 2006/04/21 17:51:58 jjanke Exp $
 ***
 * Title:	Return Limit Price of Product/BOM
 * Description:
 *			if not found: 0
 ************************************************************************/
AS
	v_Price		NUMBER;
	v_ProductPrice	NUMBER;
	--	Get BOM Product info
	CURSOR CUR_BOM IS
		SELECT b.M_ProductBOM_ID, b.BOMQty, p.IsBOM
		FROM M_PRODUCT_BOM b, M_PRODUCT p
		WHERE b.M_ProductBOM_ID=p.M_Product_ID
		  AND b.M_Product_ID=Product_ID
		  AND p.IsBOM='Y'
		  AND p.IsVerified='Y';
	--
BEGIN
	--	Try to get price from PriceList directly
	SELECT	COALESCE (SUM(PriceLimit), 0)
	INTO	v_Price
   	FROM	M_PRODUCTPRICE
	WHERE	M_PriceList_Version_ID=PriceList_Version_ID AND M_Product_ID=Product_ID;
--	DBMS_OUTPUT.PUT_LINE('Price=' || v_Price);

	--	No Price - Check if BOM
	IF (v_Price = 0) THEN
		FOR bom IN CUR_BOM LOOP
			v_ProductPrice := Bompricelimit (bom.M_ProductBOM_ID, PriceList_Version_ID);
			v_Price := v_Price + (bom.BOMQty * v_ProductPrice);
		END LOOP;
	END IF;
	--
	RETURN v_Price;
END Bompricelimit;
/

CREATE OR REPLACE FUNCTION BOMPRICELIST
(
	Product_ID 		IN NUMBER,
	PriceList_Version_ID	IN NUMBER
)
RETURN NUMBER
/*************************************************************************
 * The contents of this file are subject to the Compiere License.  You may
 * obtain a copy of the License at    http://www.compiere.org/license.html
 * Software is on an  "AS IS" basis,  WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for details. Code: Compiere ERP+CRM
 * Copyright (C) 1999-2002 Jorg Janke, ComPiere, Inc. All Rights Reserved.
 *************************************************************************
 * $Id: BOM_PriceList.sql,v 1.1 2006/04/21 17:51:58 jjanke Exp $
 ***
 * Title:	Return List Price of Product/BOM
 * Description:
 *			if not found: 0
 ************************************************************************/
AS
	v_Price			NUMBER;
	v_ProductPrice	NUMBER;
	--	Get BOM Product info
	CURSOR CUR_BOM IS
		SELECT b.M_ProductBOM_ID, b.BOMQty, p.IsBOM
		FROM M_PRODUCT_BOM b, M_PRODUCT p
		WHERE b.M_ProductBOM_ID=p.M_Product_ID
		  AND b.M_Product_ID=Product_ID
		  AND p.IsBOM='Y'
		  AND p.IsVerified='Y';
	--
BEGIN
	--	Try to get price from pricelist directly
	SELECT	COALESCE (SUM(PriceList), 0)
	INTO	v_Price
   	FROM	M_PRODUCTPRICE
	WHERE M_PriceList_Version_ID=PriceList_Version_ID AND M_Product_ID=Product_ID;
--	DBMS_OUTPUT.PUT_LINE('Price=' || Price);

	--	No Price - Check if BOM
	IF (v_Price = 0) THEN
		FOR bom IN CUR_BOM LOOP
			v_ProductPrice := Bompricelist (bom.M_ProductBOM_ID, PriceList_Version_ID);
			v_Price := v_Price + (bom.BOMQty * v_ProductPrice);
		--	DBMS_OUTPUT.PUT_LINE('Qry=' || bom.BOMQty || ' @ ' || v_ProductPrice || ', Price=' || v_Price);
		END LOOP;	--	BOM
	END IF;
	--
	RETURN v_Price;
END Bompricelist;
/

CREATE OR REPLACE FUNCTION BOMPRICESTD
(
	Product_ID 		IN NUMBER,
	PriceList_Version_ID	IN NUMBER
)
RETURN NUMBER
/*************************************************************************
 * The contents of this file are subject to the Compiere License.  You may
 * obtain a copy of the License at    http://www.compiere.org/license.html
 * Software is on an  "AS IS" basis,  WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for details. Code: Compiere ERP+CRM
 * Copyright (C) 1999-2002 Jorg Janke, ComPiere, Inc. All Rights Reserved.
 *************************************************************************
 * $Id: BOM_PriceStd.sql,v 1.1 2006/04/21 17:51:58 jjanke Exp $
 ***
 * Title:	Return Standard Price of Product/BOM
 * Description:
 *			if not found: 0
 ************************************************************************/
AS
	v_Price			NUMBER;
	v_ProductPrice	NUMBER;
	--	Get BOM Product info
	CURSOR CUR_BOM IS
		SELECT b.M_ProductBOM_ID, b.BOMQty, p.IsBOM
		FROM M_PRODUCT_BOM b, M_PRODUCT p
		WHERE b.M_ProductBOM_ID=p.M_Product_ID
		  AND b.M_Product_ID=Product_ID
		  AND p.IsBOM='Y'
		  AND p.IsVerified='Y';
	--
BEGIN
	--	Try to get price from pricelist directly
	SELECT	COALESCE(SUM(PriceStd), 0)
	INTO	v_Price
   	FROM	M_PRODUCTPRICE
	WHERE M_PriceList_Version_ID=PriceList_Version_ID AND M_Product_ID=Product_ID;
--	DBMS_OUTPUT.PUT_LINE('Price=' || v_Price);

	--	No Price - Check if BOM
	IF (v_Price = 0) THEN
		FOR bom IN CUR_BOM LOOP
			v_ProductPrice := Bompricestd (bom.M_ProductBOM_ID, PriceList_Version_ID);
			v_Price := v_Price + (bom.BOMQty * v_ProductPrice);
		--	DBMS_OUTPUT.PUT_LINE('Price=' || v_Price);
		END LOOP;	--	BOM
	END IF;
	--
	RETURN v_Price;
END Bompricestd;
/

CREATE OR REPLACE FUNCTION BOMQTYONHAND
(
	Product_ID 		IN NUMBER,
	Warehouse_ID		IN NUMBER,
	Locator_ID		IN NUMBER	--	Only used, if warehouse is null
)
RETURN NUMBER
/******************************************************************************
 * ** Compiere Product **             Copyright (c) 1999-2001 Accorto, Inc. USA
 * Open  Source  Software        Provided "AS IS" without warranty or liability
 * When you use any parts (changed or unchanged), add  "Powered by Compiere" to
 * your product name;  See license details http://www.compiere.org/license.html
 ******************************************************************************
 *	Return quantity on hand for BOM
 */
AS
	myWarehouse_ID	NUMBER;
 	Quantity		NUMBER := 99999;	--	unlimited
	IsBOM			CHAR(1);
	IsStocked		CHAR(1);
	ProductType		CHAR(1);
 	ProductQty		NUMBER;
	StdPrecision	NUMBER;
	--	Get BOM Product info
	CURSOR CUR_BOM IS
		SELECT b.M_ProductBOM_ID, b.BOMQty, p.IsBOM, p.IsStocked, p.ProductType
		FROM M_PRODUCT_BOM b, M_PRODUCT p
		WHERE b.M_ProductBOM_ID=p.M_Product_ID
		  AND b.M_Product_ID=Product_ID
		  AND p.IsBOM='Y'
		  AND p.IsVerified='Y';
	--
BEGIN
	--	Check Parameters
	myWarehouse_ID := Warehouse_ID;
	IF (myWarehouse_ID IS NULL) THEN
		IF (Locator_ID IS NULL) THEN
			RETURN 0;
		ELSE
			SELECT 	SUM(M_Warehouse_ID) INTO myWarehouse_ID
			FROM	M_LOCATOR
			WHERE	M_Locator_ID=Locator_ID;
		END IF;
	END IF;
	IF (myWarehouse_ID IS NULL) THEN
		RETURN 0;
	END IF;
--	DBMS_OUTPUT.PUT_LINE('Warehouse=' || myWarehouse_ID);

	--	Check, if product exists and if it is stocked
	BEGIN
		SELECT	IsBOM, ProductType, IsStocked
	 	  INTO	IsBOM, ProductType, IsStocked
		FROM M_PRODUCT
		WHERE M_Product_ID=Product_ID;
		--
	EXCEPTION	--	not found
		WHEN OTHERS THEN
			RETURN 0;
	END;
	--	Unimited capacity if no item
	IF (IsBOM='N' AND (ProductType<>'I' OR IsStocked='N')) THEN
		RETURN Quantity;
	--	Stocked item
	ELSIF (IsStocked='Y') THEN
		--	Get ProductQty
		SELECT 	NVL(SUM(QtyOnHand), 0)
		  INTO	ProductQty
		FROM 	M_STORAGE s
		WHERE M_Product_ID=Product_ID
		  AND EXISTS (SELECT * FROM M_LOCATOR l WHERE s.M_Locator_ID=l.M_Locator_ID
		  	AND l.M_Warehouse_ID=myWarehouse_ID);
		--
	--	DBMS_OUTPUT.PUT_LINE('Qty=' || ProductQty);
		RETURN ProductQty;
	END IF;

	--	Go though BOM
--	DBMS_OUTPUT.PUT_LINE('BOM');
	FOR bom IN CUR_BOM LOOP
		--	Stocked Items "leaf node"
		IF (bom.ProductType = 'I' AND bom.IsStocked = 'Y') THEN
			--	Get ProductQty
			SELECT 	NVL(SUM(QtyOnHand), 0)
			  INTO	ProductQty
			FROM 	M_STORAGE s
			WHERE M_Product_ID=bom.M_ProductBOM_ID
			  AND EXISTS (SELECT * FROM M_LOCATOR l WHERE s.M_Locator_ID=l.M_Locator_ID
			  	AND l.M_Warehouse_ID=myWarehouse_ID);
			--	Get Rounding Precision
			SELECT 	NVL(MAX(u.StdPrecision), 0)
			  INTO	StdPrecision
			FROM 	C_UOM u, M_PRODUCT p
			WHERE u.C_UOM_ID=p.C_UOM_ID AND p.M_Product_ID=bom.M_ProductBOM_ID;
			--	How much can we make with this product
			ProductQty := ROUND (ProductQty/bom.BOMQty, StdPrecision);
			--	How much can we make overall
			IF (ProductQty < Quantity) THEN
				Quantity := ProductQty;
			END IF;
		--	Another BOM
		ELSIF (bom.IsBOM = 'Y') THEN
			ProductQty := Bomqtyonhand (bom.M_ProductBOM_ID, myWarehouse_ID, Locator_ID);
			--	How much can we make overall
			IF (ProductQty < Quantity) THEN
				Quantity := ProductQty;
			END IF;
		END IF;
	END LOOP;	--	BOM

	IF (Quantity > 0) THEN
		--	Get Rounding Precision for Product
		SELECT 	NVL(MAX(u.StdPrecision), 0)
		  INTO	StdPrecision
		FROM 	C_UOM u, M_PRODUCT p
		WHERE u.C_UOM_ID=p.C_UOM_ID AND p.M_Product_ID=Product_ID;
		--
		RETURN ROUND (Quantity, StdPrecision);
	END IF;
	RETURN 0;
END Bomqtyonhand;
/

CREATE OR REPLACE FUNCTION BOMQTYORDERED
(
	p_Product_ID 		IN NUMBER,
	p_Warehouse_ID		IN NUMBER,
	p_Locator_ID		IN NUMBER	--	Only used, if warehouse is null
)
RETURN NUMBER
/******************************************************************************
 * ** Compiere Product **             Copyright (c) 1999-2001 Accorto, Inc. USA
 * Open  Source  Software        Provided "AS IS" without warranty or liability
 * When you use any parts (changed or unchanged), add  "Powered by Compiere" to
 * your product name;  See license details http://www.compiere.org/license.html
 ******************************************************************************
 *	Return quantity ordered for BOM
 */
AS
	v_Warehouse_ID		NUMBER;
 	v_Quantity			NUMBER := 99999;	--	unlimited
	v_IsBOM				CHAR(1);
	v_IsStocked			CHAR(1);
	v_ProductType		CHAR(1);
 	v_ProductQty		NUMBER;
	v_StdPrecision		NUMBER;
	--	Get BOM Product info
	CURSOR CUR_BOM IS
		SELECT b.M_ProductBOM_ID, b.BOMQty, p.IsBOM, p.IsStocked, p.ProductType
		FROM M_PRODUCT_BOM b, M_PRODUCT p
		WHERE b.M_ProductBOM_ID=p.M_Product_ID
		  AND b.M_Product_ID=p_Product_ID
		  AND p.IsBOM='Y'
		  AND p.IsVerified='Y';
	--
BEGIN
	--	Check Parameters
	v_Warehouse_ID := p_Warehouse_ID;
	IF (v_Warehouse_ID IS NULL) THEN
		IF (p_Locator_ID IS NULL) THEN
			RETURN 0;
		ELSE
			SELECT 	MAX(M_Warehouse_ID) INTO v_Warehouse_ID
			FROM	M_LOCATOR
			WHERE	M_Locator_ID=p_Locator_ID;
		END IF;
	END IF;
	IF (v_Warehouse_ID IS NULL) THEN
		RETURN 0;
	END IF;
--	DBMS_OUTPUT.PUT_LINE('Warehouse=' || v_Warehouse_ID);

	--	Check, if product exists and if it is stocked
	BEGIN
		SELECT	IsBOM, ProductType, IsStocked
		  INTO	v_IsBOM, v_ProductType, v_IsStocked
		FROM 	M_PRODUCT
		WHERE 	M_Product_ID=p_Product_ID;
		--
	EXCEPTION	--	not found
		WHEN OTHERS THEN
			RETURN 0;
	END;

	--	No reservation for non-stocked
	IF (v_IsBOM='N' AND (v_ProductType<>'I' OR v_IsStocked='N')) THEN
		RETURN 0;
	--	Stocked item
	ELSIF (v_IsStocked='Y') THEN
		--	Get ProductQty
		SELECT 	NVL(SUM(QtyOrdered), 0)
		  INTO	v_ProductQty
		FROM 	M_STORAGE s
		WHERE 	M_Product_ID=p_Product_ID
		  AND EXISTS (SELECT * FROM M_LOCATOR l WHERE s.M_Locator_ID=l.M_Locator_ID
		  	AND l.M_Warehouse_ID=v_Warehouse_ID);
		--
		RETURN v_ProductQty;
	END IF;

	--	Go though BOM
--	DBMS_OUTPUT.PUT_LINE('BOM');
	FOR bom IN CUR_BOM LOOP
		--	Stocked Items "leaf node"
		IF (bom.ProductType = 'I' AND bom.IsStocked = 'Y') THEN
			--	Get ProductQty
			SELECT 	NVL(SUM(QtyOrdered), 0)
			  INTO	v_ProductQty
			FROM 	M_STORAGE s
			WHERE 	M_Product_ID=bom.M_ProductBOM_ID
			  AND EXISTS (SELECT * FROM M_LOCATOR l WHERE s.M_Locator_ID=l.M_Locator_ID
			  	AND l.M_Warehouse_ID=v_Warehouse_ID);
			--	Get Rounding Precision
			SELECT 	NVL(MAX(u.StdPrecision), 0)
			  INTO	v_StdPrecision
			FROM 	C_UOM u, M_PRODUCT p
			WHERE 	u.C_UOM_ID=p.C_UOM_ID AND p.M_Product_ID=bom.M_ProductBOM_ID;
			--	How much can we make with this product
			v_ProductQty := ROUND (v_ProductQty/bom.BOMQty, v_StdPrecision);
			--	How much can we make overall
			IF (v_ProductQty < v_Quantity) THEN
				v_Quantity := v_ProductQty;
			END IF;
		--	Another BOM
		ELSIF (bom.IsBOM = 'Y') THEN
			v_ProductQty := Bomqtyordered (bom.M_ProductBOM_ID, v_Warehouse_ID, p_Locator_ID);
			--	How much can we make overall
			IF (v_ProductQty < v_Quantity) THEN
				v_Quantity := v_ProductQty;
			END IF;
		END IF;
	END LOOP;	--	BOM

	--	Unlimited (e.g. only services)
	IF (v_Quantity = 99999) THEN
		RETURN 0;
	END IF;

	IF (v_Quantity > 0) THEN
		--	Get Rounding Precision for Product
		SELECT 	NVL(MAX(u.StdPrecision), 0)
		  INTO	v_StdPrecision
		FROM 	C_UOM u, M_PRODUCT p
		WHERE 	u.C_UOM_ID=p.C_UOM_ID AND p.M_Product_ID=p_Product_ID;
		--
		RETURN ROUND (v_Quantity, v_StdPrecision);
	END IF;
	--
	RETURN 0;
END Bomqtyordered;
/

CREATE OR REPLACE FUNCTION BOMQTYRESERVED
(
	p_Product_ID 		IN NUMBER,
	p_Warehouse_ID		IN NUMBER,
	p_Locator_ID		IN NUMBER	--	Only used, if warehouse is null
)
RETURN NUMBER
/******************************************************************************
 * ** Compiere Product **             Copyright (c) 1999-2001 Accorto, Inc. USA
 * Open  Source  Software        Provided "AS IS" without warranty or liability
 * When you use any parts (changed or unchanged), add  "Powered by Compiere" to
 * your product name;  See license details http://www.compiere.org/license.html
 ******************************************************************************
 *	Return quantity reserved for BOM
 */
AS
	v_Warehouse_ID		NUMBER;
 	v_Quantity			NUMBER := 99999;	--	unlimited
	v_IsBOM				CHAR(1);
	v_IsStocked			CHAR(1);
	v_ProductType		CHAR(1);
 	v_ProductQty		NUMBER;
	v_StdPrecision		NUMBER;
	--	Get BOM Product info
	CURSOR CUR_BOM IS
		SELECT b.M_ProductBOM_ID, b.BOMQty, p.IsBOM, p.IsStocked, p.ProductType
		FROM M_PRODUCT_BOM b, M_PRODUCT p
		WHERE b.M_ProductBOM_ID=p.M_Product_ID
		  AND b.M_Product_ID=p_Product_ID
		  AND p.IsBOM='Y'
		  AND p.IsVerified='Y';
	--
BEGIN
	--	Check Parameters
	v_Warehouse_ID := p_Warehouse_ID;
	IF (v_Warehouse_ID IS NULL) THEN
		IF (p_Locator_ID IS NULL) THEN
			RETURN 0;
		ELSE
			SELECT 	MAX(M_Warehouse_ID) INTO v_Warehouse_ID
			FROM	M_LOCATOR
			WHERE	M_Locator_ID=p_Locator_ID;
		END IF;
	END IF;
	IF (v_Warehouse_ID IS NULL) THEN
		RETURN 0;
	END IF;
--	DBMS_OUTPUT.PUT_LINE('Warehouse=' || v_Warehouse_ID);

	--	Check, if product exists and if it is stocked
	BEGIN
		SELECT	IsBOM, ProductType, IsStocked
		  INTO	v_IsBOM, v_ProductType, v_IsStocked
		FROM M_PRODUCT
		WHERE M_Product_ID=p_Product_ID;
		--
	EXCEPTION	--	not found
		WHEN OTHERS THEN
			RETURN 0;
	END;

	--	No reservation for non-stocked
	IF (v_IsBOM='N' AND (v_ProductType<>'I' OR v_IsStocked='N')) THEN
		RETURN 0;
	--	Stocked item
	ELSIF (v_IsStocked='Y') THEN
		--	Get ProductQty
		SELECT 	NVL(SUM(QtyReserved), 0)
		  INTO	v_ProductQty
		FROM 	M_STORAGE s
		WHERE M_Product_ID=p_Product_ID
		  AND EXISTS (SELECT * FROM M_LOCATOR l WHERE s.M_Locator_ID=l.M_Locator_ID
		  	AND l.M_Warehouse_ID=v_Warehouse_ID);
		--
		RETURN v_ProductQty;
	END IF;

	--	Go though BOM
--	DBMS_OUTPUT.PUT_LINE('BOM');
	FOR bom IN CUR_BOM LOOP
		--	Stocked Items "leaf node"
		IF (bom.ProductType = 'I' AND bom.IsStocked = 'Y') THEN
			--	Get ProductQty
			SELECT 	NVL(SUM(QtyReserved), 0)
			  INTO	v_ProductQty
			FROM 	M_STORAGE s
			WHERE 	M_Product_ID=bom.M_ProductBOM_ID
			  AND EXISTS (SELECT * FROM M_LOCATOR l WHERE s.M_Locator_ID=l.M_Locator_ID
			  	AND l.M_Warehouse_ID=v_Warehouse_ID);
			--	Get Rounding Precision
			SELECT 	NVL(MAX(u.StdPrecision), 0)
			  INTO	v_StdPrecision
			FROM 	C_UOM u, M_PRODUCT p
			WHERE 	u.C_UOM_ID=p.C_UOM_ID AND p.M_Product_ID=bom.M_ProductBOM_ID;
			--	How much can we make with this product
			v_ProductQty := ROUND (v_ProductQty/bom.BOMQty, v_StdPrecision);
			--	How much can we make overall
			IF (v_ProductQty < v_Quantity) THEN
				v_Quantity := v_ProductQty;
			END IF;
		--	Another BOM
		ELSIF (bom.IsBOM = 'Y') THEN
			v_ProductQty := Bomqtyreserved (bom.M_ProductBOM_ID, v_Warehouse_ID, p_Locator_ID);
			--	How much can we make overall
			IF (v_ProductQty < v_Quantity) THEN
				v_Quantity := v_ProductQty;
			END IF;
		END IF;
	END LOOP;	--	BOM

	--	Unlimited (e.g. only services)
	IF (v_Quantity = 99999) THEN
		RETURN 0;
	END IF;

	IF (v_Quantity > 0) THEN
		--	Get Rounding Precision for Product
		SELECT 	NVL(MAX(u.StdPrecision), 0)
		  INTO	v_StdPrecision
		FROM 	C_UOM u, M_PRODUCT p
		WHERE 	u.C_UOM_ID=p.C_UOM_ID AND p.M_Product_ID=p_Product_ID;
		--
		RETURN ROUND (v_Quantity, v_StdPrecision);
	END IF;
	RETURN 0;
END Bomqtyreserved;
/

CREATE OR REPLACE FUNCTION BOMQTYAVAILABLE
(
	Product_ID 		IN NUMBER,
	Warehouse_ID		IN NUMBER,
	Locator_ID		IN NUMBER	--	Only used, if warehouse is null
)
RETURN NUMBER
/******************************************************************************
 * ** Compiere Product **             Copyright (c) 1999-2001 Accorto, Inc. USA
 * Open  Source  Software        Provided "AS IS" without warranty or liability
 * When you use any parts (changed or unchanged), add  "Powered by Compiere" to
 * your product name;  See license details http://www.compiere.org/license.html
 ******************************************************************************
 *	Return quantity available for BOM
 */
AS
BEGIN
	RETURN bomQtyOnHand(Product_ID, Warehouse_ID, Locator_ID)
		- bomQtyReserved(Product_ID, Warehouse_ID, Locator_ID);
END bomQtyAvailable;
/

DROP FUNCTION BOMQTYAVAILABLEASI
;

DROP FUNCTION BOMQTYONHANDASI
;

DROP FUNCTION BOMQTYORDEREDASI
;

DROP FUNCTION BOMQTYRESERVEDASI
;

-- Sep 19, 2013 8:34:08 PM COT
-- IDEMPIERE-1370 Circular Reference in Product Info when a bom product is referenced to itself and its price-lists prices are set to zero
UPDATE AD_Process SET IsActive='N',Updated=TO_DATE('2013-09-19 20:34:08','YYYY-MM-DD HH24:MI:SS'),UpdatedBy=100 WHERE AD_Process_ID=346
;

-- Sep 19, 2013 8:34:08 PM COT
UPDATE AD_Menu SET Name='Verify BOMs', Description='Verify BOM Structures', IsActive='N',Updated=TO_DATE('2013-09-19 20:34:08','YYYY-MM-DD HH24:MI:SS'),UpdatedBy=100 WHERE AD_Menu_ID=585
;

-- Sep 19, 2013 8:36:42 PM COT
UPDATE AD_Process_Para SET IsMandatory='Y', DefaultValue='Y',Updated=TO_DATE('2013-09-19 20:36:42','YYYY-MM-DD HH24:MI:SS'),UpdatedBy=100 WHERE AD_Process_Para_ID=53463
;

-- Sep 19, 2013 8:55:22 PM COT
UPDATE AD_Field SET IsReadOnly='Y',Updated=TO_DATE('2013-09-19 20:55:22','YYYY-MM-DD HH24:MI:SS'),UpdatedBy=100 WHERE AD_Field_ID=3746
;

-- Sep 19, 2013 8:55:55 PM COT
UPDATE AD_Field SET IsReadOnly='Y',Updated=TO_DATE('2013-09-19 20:55:55','YYYY-MM-DD HH24:MI:SS'),UpdatedBy=100 WHERE AD_Field_ID=59805
;

-- Sep 19, 2013 8:59:20 PM COT
UPDATE AD_Process_Para SET DefaultValue='@M_Product_ID@',Updated=TO_DATE('2013-09-19 20:59:20','YYYY-MM-DD HH24:MI:SS'),UpdatedBy=100 WHERE AD_Process_Para_ID=53461
;

-- Sep 19, 2013 8:59:36 PM COT
UPDATE AD_Process_Para SET ReadOnlyLogic='@M_Product_ID@>0',Updated=TO_DATE('2013-09-19 20:59:36','YYYY-MM-DD HH24:MI:SS'),UpdatedBy=100 WHERE AD_Process_Para_ID=53461
;

-- Sep 19, 2013 8:59:50 PM COT
UPDATE AD_Process_Para SET DisplayLogic='@M_Product_ID@=0',Updated=TO_DATE('2013-09-19 20:59:50','YYYY-MM-DD HH24:MI:SS'),UpdatedBy=100 WHERE AD_Process_Para_ID=53462
;

-- Sep 19, 2013 9:12:59 PM COT
UPDATE AD_Process_Para SET DisplayLogic='@M_Product_ID@=0',Updated=TO_DATE('2013-09-19 21:12:59','YYYY-MM-DD HH24:MI:SS'),UpdatedBy=100 WHERE AD_Process_Para_ID=53463
;

-- Sep 19, 2013 9:21:47 PM COT
UPDATE M_Product SET IsVerified='Y',Updated=TO_DATE('2013-09-19 21:21:47','YYYY-MM-DD HH24:MI:SS'),UpdatedBy=100 WHERE M_Product_ID=133
;

-- Sep 19, 2013 9:21:47 PM COT
UPDATE M_Product SET IsVerified='Y',Updated=TO_DATE('2013-09-19 21:21:47','YYYY-MM-DD HH24:MI:SS'),UpdatedBy=100 WHERE M_Product_ID=145
;

-- Sep 19, 2013 9:22:10 PM COT
UPDATE M_Product SET IsVerified='Y',Updated=TO_DATE('2013-09-19 21:22:10','YYYY-MM-DD HH24:MI:SS'),UpdatedBy=100 WHERE M_Product_ID=50001
;

-- Sep 19, 2013 9:44:39 PM COT
UPDATE M_Product SET IsVerified='Y',Updated=TO_DATE('2013-09-19 21:44:39','YYYY-MM-DD HH24:MI:SS'),UpdatedBy=100 WHERE M_Product_ID=50000
;

SELECT register_migration_script('201309192024_IDEMPIERE-1370.sql') FROM dual
;

