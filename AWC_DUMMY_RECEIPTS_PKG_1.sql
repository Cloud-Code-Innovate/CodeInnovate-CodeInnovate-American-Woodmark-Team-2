--------------------------------------------------------
--  DDL for Package Body AWC_DUMMY_RECEIPTS_PKG
--------------------------------------------------------
create or replace PACKAGE BODY "AWC_DUMMY_RECEIPTS_PKG" AS
/****************************************************************************
    *
    * NAME:        AWC_DUMMY_RECEIPTS_PKG.pkb
    * PURPOSE:     Custom package for Receipts Inbound
    *
    * REVISIONS
    *
    * VERSION   DATE         AUTHOR(S)            DESCRIPTION
    * -------   ----------   --------------       ------------------------ 
    * 1.0       17-MAR-2021  Baljeet Oberoi      Initial version
   /*****************************AWC_POR_REQUISITION_PKG Body**********************************************/

   /**********************************************************************************
     Name              : checkDuplicatFile
     Purpose           : Check if file name is duplicate
     ************************************************************************************/

PROCEDURE checkDuplicatFile (p_file_name IN VARCHAR2, p_status OUT VARCHAR2, p_message OUT VARCHAR2)
AS

l_record_count NUMBER DEFAULT 0;

BEGIN
    p_status := NULL;
    p_message := NULL;

    l_record_count := 0;

     -- Checking if the same file has been staged before
     Select count(*)
     into l_record_count
     from AWC_DUMMY_TBL_2
     where file_name = p_file_name;

     IF (l_record_count > 0) THEN

        p_status := 'ERROR';
        p_message := 'The file '||p_file_name||' has already been processed earlier.';

     ELSE

        p_status := 'SUCCESS';

     END IF;

    EXCEPTION WHEN OTHERS
    THEN
        p_status := 'ERROR';
        p_message := 'Error in checking duplicate file: '||SQLERRM;

END;

   /**********************************************************************************
     Name              : createPorXRefData
     Purpose           : Load input data to staging table
     ************************************************************************************/

PROCEDURE createPoXRefData (p_xref_inputs IN AWC_PO_RECEIPT_INPUT_TBL , p_status OUT VARCHAR2, p_message OUT VARCHAR2)
AS

BEGIN

    p_status := NULL;
    p_message := NULL;

        FORALL i IN p_xref_inputs.FIRST .. p_xref_inputs.LAST SAVE EXCEPTIONS
            -- Inserting input data from file into staging table
    Insert into AWC_DUMMY_TBL_2 (PO_XREF_ID,
                                        FLOW_ID,
                                        FILE_NAME,
                                        SENTLOC,
                                        BILLOFLADING,
                                        PALLET,
                                        RECNO,
                                        TYPE,
                                        ACTION,
                                        UPLDDATE,
                                        BUYENT,
                                        PONUM,
                                        POLINE,
                                        POPALLET,
                                        POBLNKTREL,
                                        POPACKSLIP,
                                        POITEMCTLG,
                                        POITEM,
                                        POUOM,
                                        PODELDATE,
                                        POQTYR,
                                        POCARR,
                                        POORIG,
                                        POBOL,
                                        POWEIGHT,
                                        PONOTES,
                                        ULDT,
                                        PROCESSED,
                                        COMPLETE,
                                        USERID,
                                        PUTAWAYHOLD,
                                        RECEIVEDDATE,
                                        SHIPPEDDATE,
                                        CREATION_DATE,
                                        CREATED_BY,
                                        LAST_UPDATE_DATE,
                                        LAST_UPDATED_BY)
                values (PO_XREF_ID_S.NEXTVAL		       , 
                                        LTRIM(RTRIM(p_xref_inputs(i).FLOW_ID)),
                                        p_xref_inputs(i).FILE_NAME,
                                        p_xref_inputs(i).SENTLOC,
                                        LTRIM(RTRIM(p_xref_inputs(i).BILLOFLADING)),
                                        LTRIM(RTRIM(p_xref_inputs(i).PALLET)),
                                        LTRIM(RTRIM(p_xref_inputs(i).RECNO)),
                                        LTRIM(RTRIM(p_xref_inputs(i).TYPE)),
                                        LTRIM(RTRIM(p_xref_inputs(i).ACTION)),
                                        LTRIM(RTRIM(p_xref_inputs(i).UPLDDATE)),
                                        LTRIM(RTRIM(p_xref_inputs(i).BUYENT)),
                                        LTRIM(RTRIM(p_xref_inputs(i).PONUM)),
                                        LTRIM(RTRIM(p_xref_inputs(i).POLINE)),
                                        LTRIM(RTRIM(p_xref_inputs(i).POPALLET)),
                                        LTRIM(RTRIM(p_xref_inputs(i).POBLNKTREL)),
                                        LTRIM(RTRIM(p_xref_inputs(i).POPACKSLIP)),
                                        LTRIM(RTRIM(p_xref_inputs(i).POITEMCTLG)),
                                        LTRIM(RTRIM(p_xref_inputs(i).POITEM)),
                                        LTRIM(RTRIM(p_xref_inputs(i).POUOM)),
                                        LTRIM(RTRIM(p_xref_inputs(i).PODELDATE)),
                                        LTRIM(RTRIM(p_xref_inputs(i).POQTYR)),
                                        LTRIM(RTRIM(p_xref_inputs(i).POCARR)),
                                        LTRIM(RTRIM(p_xref_inputs(i).POORIG)),
                                        LTRIM(RTRIM(p_xref_inputs(i).POBOL)),
                                        LTRIM(RTRIM(p_xref_inputs(i).POWEIGHT)),
                                        LTRIM(RTRIM(p_xref_inputs(i).PONOTES)),
                                        LTRIM(RTRIM(p_xref_inputs(i).ULDT)),
                                        LTRIM(RTRIM(p_xref_inputs(i).PROCESSED)),
                                        LTRIM(RTRIM(p_xref_inputs(i).COMPLETE)),
                                        LTRIM(RTRIM(p_xref_inputs(i).USERID)),
                                        LTRIM(RTRIM(p_xref_inputs(i).PUTAWAYHOLD)),
                                        LTRIM(RTRIM(p_xref_inputs(i).RECEIVEDDATE)),
                                        LTRIM(RTRIM(p_xref_inputs(i).SHIPPEDDATE)),
                                        p_xref_inputs(i).CREATION_DATE,
                                        p_xref_inputs(i).CREATED_BY,
                                        p_xref_inputs(i).LAST_UPDATE_DATE,
                                        p_xref_inputs(i).LAST_UPDATED_BY); 

    COMMIT;

    p_status := 'SUCCESS';
    p_message := 'Input data loded successfully';

    EXCEPTION WHEN OTHERS
    THEN
        p_status := 'ERROR';
        p_message := 'Error in receiving input data: '||SQLERRM;

END;

     /**********************************************************************************
     Name              : poSupplierSyncXRefData
     Purpose           : Load PO Supplier data to sync table
     ************************************************************************************/

PROCEDURE poSupplierSyncXRefData (p_xref_inputs IN AWC_PO_SUP_INPUT_TBL, p_status OUT VARCHAR2, p_message OUT VARCHAR2)
AS

l_record_count NUMBER DEFAULT 0;

BEGIN

    p_status := NULL;
    p_message := NULL;

        FOR i IN p_xref_inputs.FIRST .. p_xref_inputs.LAST
        LOOP

        -- Check Insert/Update
        Select count(1)
        into l_record_count
        from AWC_PO_SUP_TBL
        where PO_NUM = p_xref_inputs(i).PO_NUM;

IF (l_record_count > 0) THEN
        -- UPDATING input data from file into staging table
    Update AWC_PO_SUP_TBL
        Set DOCUMENT_STATUS = p_xref_inputs(i).DOCUMENT_STATUS,
            SUPPL_NUM = p_xref_inputs(i).SUPPL_NUM,
            VENDOR_NAME= p_xref_inputs(i).VENDOR_NAME,
            VENDOR_SITE_CODE = p_xref_inputs(i).VENDOR_SITE_CODE,
            LAST_UPDATED_BY   =  p_xref_inputs(i).LAST_UPDATED_BY,
            LAST_UPDATE_DATE  =   p_xref_inputs(i).LAST_UPDATE_DATE
    where PO_NUM = p_xref_inputs(i).PO_NUM;

ELSE
        -- Inserting input data from file into staging table
        Insert into AWC_PO_SUP_TBL ( POSUP_XREF_ID,
                        PO_NUM,
                        DOCUMENT_STATUS,
                        SUPPL_NUM , 
                        VENDOR_NAME,
                        VENDOR_SITE_CODE,
                        CREATED_BY,
                        CREATION_DATE,
                        LAST_UPDATED_BY,
                        LAST_UPDATE_DATE)
                                values (POSUP_XREF_ID_S.NEXTVAL,
                                        p_xref_inputs(i).PO_NUM,
                                        p_xref_inputs(i).DOCUMENT_STATUS,
                                        p_xref_inputs(i).SUPPL_NUM,
                                        p_xref_inputs(i).VENDOR_NAME,
                                        p_xref_inputs(i).VENDOR_SITE_CODE,
                                        p_xref_inputs(i).CREATED_BY,
                                        p_xref_inputs(i).CREATION_DATE,
                                        p_xref_inputs(i).LAST_UPDATED_BY,
                                        p_xref_inputs(i).LAST_UPDATE_DATE);

END IF;
   END LOOP;
COMMIT;

    p_status := 'SUCCESS';
    p_message := 'PO Supplier Sync data loded successfully';

    EXCEPTION WHEN OTHERS
    THEN
        p_status := 'ERROR';
        p_message := 'Error in syncing PO Supplier data: '||SQLERRM;

END;

/**********************************************************************************
     Name              : ReceiptHeaderLoadStage
     Purpose           : Generate data for Requisition Lines
************************************************************************************/

PROCEDURE ReceiptHeaderLoadStage (p_flow_id IN VARCHAR2, p_user IN VARCHAR, p_status OUT VARCHAR2, p_message OUT VARCHAR2)
AS
CURSOR c_input
IS (Select 		A.BillOfLading,
				A.POPackSlip,
				A.ShippedDate,
				A.PONotes,
				A.POWeight,
				A.ReceivedDate,
                A.UserID AS USERID,
                (SELECT VALUE FROM AWC_RECEIPT_EMP_TBL where UPPER(LOOKUPCODE) = 'MRP') AS Employee_Name,
                A.PO_XREF_ID
    from AWC_DUMMY_TBL_2 A
    where flow_id = p_flow_id);

l_interface_key    NUMBER DEFAULT 0;
l_rec_id                NUMBER DEFAULT 0;

BEGIN

    p_status := NULL;
    p_message := NULL;

    l_interface_key := 1;
    l_rec_id := 1;

    FOR i in c_input
    LOOP

    -- Load Item and Org from inbound tbl to lines tbl
    Insert into AWC_DUMMY_TBL_1(HEADER_ID,
                                    FLOW_ID,
									Source,
									Header_Interface_Number,
                                    Employee_Name,
									Receipt_SRC_Code,
  									Trans_Type,
									Bill_of_Landing,
									Packing_Slip,
									Ship_Date,
									Comments,
									Gross_Weight,
									Transaction_Date,
									Business_Unit,
                                    CREATED_BY,
                                    CREATION_DATE,
                                    LAST_UPDATED_BY,
                                    LAST_UPDATE_DATE,
                                    REC_ID,
                                    PO_XREF_ID,
                                    ATTRIBUTE2)
                              values (RCPT_HDR_ID_S.NEXTVAL + 10,
                                      p_flow_id,
									  'LEGACY MRP',
                                      'G_RECEIPT_MRP_HDR_'||l_interface_key,
                                      i.Employee_Name,
									  'VENDOR',
									  'NEW',
									  i.BillOfLading,
									  i.POPackSlip,
                                      TO_CHAR(TO_DATE(SUBSTR( i.ShippedDate,1,10),'yyyy/mm/dd'),'YYYY/MM/DD') ,
									  i.PONotes,
									  i.POWeight,
                                      TO_CHAR(TO_DATE(SUBSTR( i.ReceivedDate,1,10),'yyyy/mm/dd'),'YYYY/MM/DD'),
									  'US BU',
                                      p_user,
                                      sysdate,
                                      p_user,
                                      sysdate,
                                      l_rec_id,
                                      i.PO_XREF_ID,
                                      i.USERID);

    l_interface_key := l_interface_key + 1;
    l_rec_id := l_rec_id + 1;


    END LOOP;

UPDATE AWC_DUMMY_TBL_1 A
SET (Supplier_Name,Supplier_Num,Supplier_Site_Code) = (SELECT VENDOR_NAME,SUPPL_NUM,VENDOR_SITE_CODE FROM AWC_PO_SUP_TBL B, AWC_DUMMY_TBL_2 C 
														WHERE C.PONum = B.PO_NUM
														AND B.DOCUMENT_STATUS IN ('CLOSED','CLOSED FOR INVOICING','CLOSED FOR RECEIVING','OPEN')
														AND C.PO_XREF_ID = A.PO_XREF_ID)
where A.flow_id = p_flow_id
AND EXISTS (SELECT 'X' FROM AWC_PO_SUP_TBL B, AWC_DUMMY_TBL_2 C 
														WHERE C.PONum = B.PO_NUM
														AND B.DOCUMENT_STATUS IN ('CLOSED','CLOSED FOR INVOICING','CLOSED FOR RECEIVING','OPEN')
														AND C.PO_XREF_ID = A.PO_XREF_ID);

    COMMIT;

    p_status := 'SUCCESS';
    p_message := 'Receipt Header data created successfully';

    EXCEPTION WHEN OTHERS
    THEN

        p_status := 'ERROR';
        p_message := 'Error in creating Receipt Header data: '||SQLERRM;

END;

/**********************************************************************************
     Name              : ReceiptLineLoadStage
     Purpose           : Generate data for Requisition Lines
     ************************************************************************************/

PROCEDURE ReceiptLineLoadStage (p_flow_id IN VARCHAR2, p_user IN VARCHAR, p_status OUT VARCHAR2, p_message OUT VARCHAR2)
AS
CURSOR c_input
IS (Select 		POItem,
				PONum,
				POQtyr,
				ReceivedDate,
				BuyEnt,
				POLine,
				POUom,
				BillOfLading,
				POPackSlip,
				ShippedDate,
				PONotes,
				UserID,
                (SELECT VALUE FROM AWC_RECEIPT_EMP_TBL where UPPER(LOOKUPCODE) = 'MRP') AS Employee_Name,
				POPallet,
				POCarr,
				PO_XREF_ID,
				(SELECT Header_Interface_Number FROM AWC_DUMMY_TBL_1 B WHERE B.flow_id = A.flow_id AND B.PO_XREF_ID = A.PO_XREF_ID) AS Header_Interface_Number
    from AWC_DUMMY_TBL_2 A
    where A.flow_id = p_flow_id);


l_interface_key    NUMBER DEFAULT 0;
l_rec_id                NUMBER DEFAULT 0;

BEGIN

    p_status := NULL;
    p_message := NULL;

    l_rec_id := 1;

    FOR i in c_input
    LOOP

    -- Load Item and Org from inbound tbl to lines tbl
    Insert into AWC_PO_RECEIPT_LINE_TBL(LINE_ID,
                                    FLOW_ID,
									Source,
									Item_Number,
									Document_Number,
									Quantity,
									Employee_Name,
									Interface_Line_Number,
									Transaction_Type,
									Auto_Transact_Code,
									Transaction_Date,
									Source_Document_Code,
									Receipt_Source_Code,
									Header_Interface_Number,
									Organization_Code,
									Document_Line_Number,
									Document_Schedule_Number,
									Document_Distribution_Number,
									Business_Unit,
									UOM,
									Routing_Header_ID,
									Interface_Source_Code,
									Carrier_Name,
									Bill_of_Lading,
									Packing_Slip,
									Shipped_Date,
									Comments,
									Attribute_Category,
									ATTRIBUTE1,
									ATTRIBUTE2,
									ATTRIBUTE3,
                                    CREATED_BY,
                                    CREATION_DATE,
                                    LAST_UPDATED_BY,
                                    LAST_UPDATE_DATE,
                                    REC_ID,
									PO_XREF_ID)
                              values (RCPT_LINE_ID_S.NEXTVAL + 10,
                                      p_flow_id,
									  'LEGACY MRP',
									substr(i.POItem, 3),
									i.PONum,
									i.POQtyr,
									i.Employee_Name,
									REPLACE(i.Header_Interface_Number, 'HDR', 'LINE') ,
									'RECEIVE',
									'DELIVER',
                                    TO_CHAR(TO_DATE(SUBSTR(i.ReceivedDate,1,10),'yyyy/mm/dd'),'YYYY/MM/DD'),
									'PO',
									'VENDOR',
									i.Header_Interface_Number,
									i.BuyEnt,
									i.POLine,
									1,
									1,
									'US BU',
									i.POUom,
									3,
									'LEGACY MRP',
									' ',
									i.BillOfLading,
									i.POPackSlip,
                                    TO_CHAR(TO_DATE(SUBSTR(i.ShippedDate,1,10),'yyyy/mm/dd'),'YYYY/MM/DD'),
									i.PONotes,
									'LEGACY INFORMATION',
									i.UserID,
									i.POPallet,
									i.POCarr,
                                      p_user,
                                      sysdate,
                                      p_user,
                                      sysdate,
                                      l_rec_id,
									  i.PO_XREF_ID);
    l_rec_id := l_rec_id + 1;


    END LOOP;

  UPDATE AWC_PO_RECEIPT_LINE_TBL A
  SET UOM = (SELECT B.UNIT_OF_MEASURE FROM AWC_RECEIPT_UOM_SYNC B WHERE B.UOM_CODE = A.UOM)
  WHERE A.flow_id = p_flow_id
  AND EXISTS (SELECT 'X' FROM AWC_RECEIPT_UOM_SYNC B WHERE B.UOM_CODE = A.UOM);

  --update HEader UOM based on Line UOM
  update AWC_DUMMY_TBL_1 A 
    set A.GROSS_WEIGHT_UOM  = (select UOM FROM AWC_PO_RECEIPT_LINE_TBL B 
                            WHERE A.FLOW_ID = B.FLOW_ID 
                            AND A.HEADER_INTERFACE_NUMBER = B.HEADER_INTERFACE_NUMBER 
                            AND A.PO_XREF_ID = B.PO_XREF_ID 
                            and B.UOM IS NOT NULL ) 
   WHERE A.GROSS_WEIGHT IS NOT NULL 
    AND EXISTS (select UOM FROM AWC_PO_RECEIPT_LINE_TBL B 
                            WHERE A.FLOW_ID = B.FLOW_ID 
                            AND A.HEADER_INTERFACE_NUMBER = B.HEADER_INTERFACE_NUMBER 
                            AND A.PO_XREF_ID = B.PO_XREF_ID 
                            and B.UOM IS NOT NULL) 
    AND A.flow_id = p_flow_id;


    COMMIT;

    p_status := 'SUCCESS';
    p_message := 'Receipt lines data created successfully';

    EXCEPTION WHEN OTHERS
    THEN
        p_status := 'ERROR';
        p_message := 'Error in creating Receipt lines data: '||SQLERRM;

END;

     /**********************************************************************************
     Name              : USERIDEMPLSyncXRefData
     Purpose           : Load USER ID and Employee Name Legacy Mapping to sync table
     ************************************************************************************/

PROCEDURE USERIDEMPLSyncXRefData (p_xref_inputs IN AWC_RECEIPT_EMP_TYPE_TBL, p_status OUT VARCHAR2, p_message OUT VARCHAR2)
AS

BEGIN

    p_status := NULL;
    p_message := NULL;

        FORALL i IN p_xref_inputs.FIRST .. p_xref_inputs.LAST SAVE EXCEPTIONS

        -- Inserting input data from file into staging table
        Insert into AWC_RECEIPT_EMP_TBL ( RECEIPT_EMP_XREF_ID,
                        LOOKUPCODE,
                        NAME , 
                        VALUE,
                        TAG,
                        CREATED_BY,
                        CREATION_DATE,
                        LAST_UPDATED_BY,
                        LAST_UPDATE_DATE)
                                values (RECEIPT_EMP_XREF_ID_S.NEXTVAL,
                                        p_xref_inputs(i).LOOKUPCODE,
                                        p_xref_inputs(i).NAME,
                                        p_xref_inputs(i).VALUE,
                                        p_xref_inputs(i).TAG,
                                        p_xref_inputs(i).CREATED_BY,
                                        p_xref_inputs(i).CREATION_DATE,
                                        p_xref_inputs(i).LAST_UPDATED_BY,
                                        p_xref_inputs(i).LAST_UPDATE_DATE);

        COMMIT;

    p_status := 'SUCCESS';
    p_message := 'Employee Sync data loaded successfully';

    EXCEPTION WHEN OTHERS
    THEN
        p_status := 'ERROR';
        p_message := 'Error in syncing Employee data: '||SQLERRM;

END;

/**********************************************************************************
     Name              : getHdrsFBDIData
     Purpose           : Get FBDI data for Receipt Headers
     ************************************************************************************/

PROCEDURE getHdrsFBDIData (p_flow_id IN VARCHAR2, p_start_index IN NUMBER, p_end_index IN NUMBER, p_receipt_headers_out OUT AWC_PO_RECEIPT_HDR_TYPE_TBL, p_status OUT VARCHAR2, p_message OUT VARCHAR2)
AS

CURSOR c_hdrs
IS
     	Select		Header_Interface_Number as Header_Interface_Number ,
					Receipt_SRC_Code,
					ASN,
					Trans_Type,
					Notice_Cr_Dt,
					Shipment_Num,
					Receipt_Num,
					Supplier_Name,
					Supplier_Num,
					Supplier_Site_Code,
					From_Org_Code,
					Ship_to_Org_Code,
					Location_Code,
					Bill_of_Landing,
					Packing_Slip,
					Ship_Date,
					Carrier_Name,
					Expt_Rcpt_Dt,
					Num_Containers,
					Waybill,
					Comments,
					Gross_Weight,
					Gross_Weight_UOM,
					Net_Weight,
					Net_Weight_UOM,
					Tare_Weight,
					Tare_Weight_UOM,
					Packaging_Code,
					Carrier_Method,
					Carrier_Equipment,
					Special_Handling_Code,
					Hazard_Code,
					Hazard_Class,
					Hazard_Desc,
					Freight_Terms,
					Freight_Bill_Number,
					Invoice_Number,
					Invoice_Date,
					Total_Invoice_Amount,
					Tax_Name,
					Tax_Amount,
					Freight_Amount,
					Currency,
					Conv_Rate_Type,
					Conv_Rate,
					Conv_Rate_Date,
					Payment_Terms_Name,
					Employee_Name,
					Transaction_Date,
					Customer_Account_Number,
					Customer_Name,
					Customer_Number,
					Business_Unit,
					Logistics_Cust_Party_Name,
					Receipt_Advice_Num,
					Receipt_Advice_Code,
					Receipt_Advice_Doc_Num,
					Receipt_Advice_Rev,
					Receipt_Advice_Rev_Dt,
					Receipt_Advice_Cr_Dt,
					Receipt_Advice_Lst_Updt,
					Receipt_Advice_Cnct_Name,
					Receipt_Advice_Supplier,
					Receipt_Advice_Notes,
					Receipt_Advice_Name,
					Attribute_Category,
					ATTRIBUTE1,
					ATTRIBUTE2,
					ATTRIBUTE3,
					ATTRIBUTE4,
					ATTRIBUTE5,
					ATTRIBUTE6,
					ATTRIBUTE7,
					ATTRIBUTE8,
					ATTRIBUTE9,
					ATTRIBUTE10,
					ATTRIBUTE11,
					ATTRIBUTE12,
					ATTRIBUTE13,
					ATTRIBUTE14,
					ATTRIBUTE15,
					ATTRIBUTE16,
					ATTRIBUTE17,
					ATTRIBUTE18,
					ATTRIBUTE19,
					ATTRIBUTE20,
					ATTRIBUTE_NUMBER1,
					ATTRIBUTE_NUMBER2,
					ATTRIBUTE_NUMBER3,
					ATTRIBUTE_NUMBER4,
					ATTRIBUTE_NUMBER5,
					ATTRIBUTE_NUMBER6,
					ATTRIBUTE_NUMBER7,
					ATTRIBUTE_NUMBER8,
					ATTRIBUTE_NUMBER9,
					ATTRIBUTE_NUMBER10,
					ATTRIBUTE_DATE1,
					ATTRIBUTE_DATE2,
					ATTRIBUTE_DATE3,
					ATTRIBUTE_DATE4,
					ATTRIBUTE_DATE5,
					ATTRIBUTE_TIMESTAMP1,
					ATTRIBUTE_TIMESTAMP2,
					ATTRIBUTE_TIMESTAMP3,
					ATTRIBUTE_TIMESTAMP4,
					ATTRIBUTE_TIMESTAMP5,
					GL_Date,
					Receipt_Header_ID,
					Ext_Sys_Trans_Ref
    from AWC_DUMMY_TBL_1
    where flow_id = p_flow_id
    and rec_id >= p_start_index
    and rec_id <= p_end_index
    and status is null
    order by rec_id;

    TYPE l_fbdi_receipt_data IS TABLE OF c_hdrs%ROWTYPE
    INDEX BY PLS_INTEGER;

    l_fbdi_receipt_tbl l_fbdi_receipt_data;

BEGIN

    p_status := NULL;
    p_message := NULL;

    OPEN c_hdrs;
    FETCH c_hdrs BULK COLLECT INTO l_fbdi_receipt_tbl;
    CLOSE c_hdrs;

    IF l_fbdi_receipt_tbl.COUNT > 0
    THEN

        p_receipt_headers_out := AWC_PO_RECEIPT_HDR_TYPE_TBL();

        FOR i IN 1..l_fbdi_receipt_tbl.COUNT
        LOOP
            p_receipt_headers_out.EXTEND;
            p_receipt_headers_out(p_receipt_headers_out.COUNT) := AWC_PO_RECEIPT_HDR_TYPE(null, null, null, null, null, null, null, null, null, null,
																						  null, null, null, null, null, null, null, null, null, null,
																						  null, null, null, null, null, null, null, null, null, null,
																						  null, null, null, null, null, null, null, null, null, null,
																						  null, null, null, null, null, null, null, null, null, null,
																						  null, null, null, null, null, null, null, null, null, null,
																						  null, null, null, null, null, null, null, null, null, null,
                                                                                          null, null, null, null, null, null, null, null, null, null,
                                                                                          null, null, null, null, null, null, null, null, null, null,
                                                                                          null, null, null, null, null, null, null, null, null, null,
                                                                                          null, null, null, null, null, null, null, null, null, null,
                                                                                          null, null, null, null, null, null, null, null, null, null,null,null );
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Header_Interface_Number           :=l_fbdi_receipt_tbl(i).Header_Interface_Number;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Receipt_SRC_Code                  :=l_fbdi_receipt_tbl(i).Receipt_SRC_Code;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).ASN                               :=l_fbdi_receipt_tbl(i).ASN;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Trans_Type                        :=l_fbdi_receipt_tbl(i).Trans_Type;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Notice_Cr_Dt                      :=l_fbdi_receipt_tbl(i).Notice_Cr_Dt;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Shipment_Num                      :=l_fbdi_receipt_tbl(i).Shipment_Num;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Receipt_Num                       :=l_fbdi_receipt_tbl(i).Receipt_Num;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Supplier_Name                     :=l_fbdi_receipt_tbl(i).Supplier_Name;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Supplier_Num                      :=l_fbdi_receipt_tbl(i).Supplier_Num;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Supplier_Site_Code                :=l_fbdi_receipt_tbl(i).Supplier_Site_Code;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).From_Org_Code                     :=l_fbdi_receipt_tbl(i).From_Org_Code;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Ship_to_Org_Code                  :=l_fbdi_receipt_tbl(i).Ship_to_Org_Code;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Location_Code                     :=l_fbdi_receipt_tbl(i).Location_Code;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Bill_of_Landing                   :=l_fbdi_receipt_tbl(i).Bill_of_Landing;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Packing_Slip                      :=l_fbdi_receipt_tbl(i).Packing_Slip;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Ship_Date                         :=l_fbdi_receipt_tbl(i).Ship_Date;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Carrier_Name                      :=l_fbdi_receipt_tbl(i).Carrier_Name;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Expt_Rcpt_Dt                      :=l_fbdi_receipt_tbl(i).Expt_Rcpt_Dt;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Num_Containers                    :=l_fbdi_receipt_tbl(i).Num_Containers;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Waybill                           :=l_fbdi_receipt_tbl(i).Waybill;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Comments                          :=l_fbdi_receipt_tbl(i).Comments;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Gross_Weight                      :=l_fbdi_receipt_tbl(i).Gross_Weight;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Gross_Weight_UOM                  :=l_fbdi_receipt_tbl(i).Gross_Weight_UOM;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Net_Weight                        :=l_fbdi_receipt_tbl(i).Net_Weight;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Net_Weight_UOM                    :=l_fbdi_receipt_tbl(i).Net_Weight_UOM;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Tare_Weight                       :=l_fbdi_receipt_tbl(i).Tare_Weight;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Tare_Weight_UOM                   :=l_fbdi_receipt_tbl(i).Tare_Weight_UOM;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Packaging_Code                    :=l_fbdi_receipt_tbl(i).Packaging_Code;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Carrier_Method                    :=l_fbdi_receipt_tbl(i).Carrier_Method;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Carrier_Equipment                 :=l_fbdi_receipt_tbl(i).Carrier_Equipment;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Special_Handling_Code             :=l_fbdi_receipt_tbl(i).Special_Handling_Code;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Hazard_Code                       :=l_fbdi_receipt_tbl(i).Hazard_Code;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Hazard_Class                      :=l_fbdi_receipt_tbl(i).Hazard_Class;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Hazard_Desc                       :=l_fbdi_receipt_tbl(i).Hazard_Desc;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Freight_Terms                     :=l_fbdi_receipt_tbl(i).Freight_Terms;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Freight_Bill_Number               :=l_fbdi_receipt_tbl(i).Freight_Bill_Number;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Invoice_Number                    :=l_fbdi_receipt_tbl(i).Invoice_Number;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Invoice_Date                      :=l_fbdi_receipt_tbl(i).Invoice_Date;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Total_Invoice_Amount              :=l_fbdi_receipt_tbl(i).Total_Invoice_Amount;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Tax_Name                          :=l_fbdi_receipt_tbl(i).Tax_Name;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Tax_Amount                        :=l_fbdi_receipt_tbl(i).Tax_Amount;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Freight_Amount                    :=l_fbdi_receipt_tbl(i).Freight_Amount;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Currency                          :=l_fbdi_receipt_tbl(i).Currency;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Conv_Rate_Type                    :=l_fbdi_receipt_tbl(i).Conv_Rate_Type;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Conv_Rate                         :=l_fbdi_receipt_tbl(i).Conv_Rate;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Conv_Rate_Date                    :=l_fbdi_receipt_tbl(i).Conv_Rate_Date;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Payment_Terms_Name                :=l_fbdi_receipt_tbl(i).Payment_Terms_Name;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Employee_Name                     :=l_fbdi_receipt_tbl(i).Employee_Name;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Transaction_Date                  :=l_fbdi_receipt_tbl(i).Transaction_Date;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Customer_Account_Number           :=l_fbdi_receipt_tbl(i).Customer_Account_Number;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Customer_Name                     :=l_fbdi_receipt_tbl(i).Customer_Name;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Customer_Number                   :=l_fbdi_receipt_tbl(i).Customer_Number;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Business_Unit                     :=l_fbdi_receipt_tbl(i).Business_Unit;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Logistics_Cust_Party_Name         :=l_fbdi_receipt_tbl(i).Logistics_Cust_Party_Name;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Receipt_Advice_Num                :=l_fbdi_receipt_tbl(i).Receipt_Advice_Num;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Receipt_Advice_Code               :=l_fbdi_receipt_tbl(i).Receipt_Advice_Code;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Receipt_Advice_Doc_Num            :=l_fbdi_receipt_tbl(i).Receipt_Advice_Doc_Num;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Receipt_Advice_Rev                :=l_fbdi_receipt_tbl(i).Receipt_Advice_Rev;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Receipt_Advice_Rev_Dt             :=l_fbdi_receipt_tbl(i).Receipt_Advice_Rev_Dt;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Receipt_Advice_Cr_Dt              :=l_fbdi_receipt_tbl(i).Receipt_Advice_Cr_Dt;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Receipt_Advice_Lst_Updt           :=l_fbdi_receipt_tbl(i).Receipt_Advice_Lst_Updt;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Receipt_Advice_Cnct_Name          :=l_fbdi_receipt_tbl(i).Receipt_Advice_Cnct_Name;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Receipt_Advice_Supplier           :=l_fbdi_receipt_tbl(i).Receipt_Advice_Supplier;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Receipt_Advice_Notes              :=l_fbdi_receipt_tbl(i).Receipt_Advice_Notes;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Receipt_Advice_Name               :=l_fbdi_receipt_tbl(i).Receipt_Advice_Name;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Attribute_Category                :=l_fbdi_receipt_tbl(i).Attribute_Category;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).ATTRIBUTE1                        :=l_fbdi_receipt_tbl(i).ATTRIBUTE1;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).ATTRIBUTE2                        :=l_fbdi_receipt_tbl(i).ATTRIBUTE2;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).ATTRIBUTE3                        :=l_fbdi_receipt_tbl(i).ATTRIBUTE3;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).ATTRIBUTE4                        :=l_fbdi_receipt_tbl(i).ATTRIBUTE4;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).ATTRIBUTE5                        :=l_fbdi_receipt_tbl(i).ATTRIBUTE5;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).ATTRIBUTE6                        :=l_fbdi_receipt_tbl(i).ATTRIBUTE6;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).ATTRIBUTE7                        :=l_fbdi_receipt_tbl(i).ATTRIBUTE7;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).ATTRIBUTE8                        :=l_fbdi_receipt_tbl(i).ATTRIBUTE8;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).ATTRIBUTE9                        :=l_fbdi_receipt_tbl(i).ATTRIBUTE9;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).ATTRIBUTE10                       :=l_fbdi_receipt_tbl(i).ATTRIBUTE10;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).ATTRIBUTE11                       :=l_fbdi_receipt_tbl(i).ATTRIBUTE11;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).ATTRIBUTE12                       :=l_fbdi_receipt_tbl(i).ATTRIBUTE12;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).ATTRIBUTE13                       :=l_fbdi_receipt_tbl(i).ATTRIBUTE13;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).ATTRIBUTE14                       :=l_fbdi_receipt_tbl(i).ATTRIBUTE14;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).ATTRIBUTE15                       :=l_fbdi_receipt_tbl(i).ATTRIBUTE15;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).ATTRIBUTE16                       :=l_fbdi_receipt_tbl(i).ATTRIBUTE16;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).ATTRIBUTE17                       :=l_fbdi_receipt_tbl(i).ATTRIBUTE17;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).ATTRIBUTE18                       :=l_fbdi_receipt_tbl(i).ATTRIBUTE18;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).ATTRIBUTE19                       :=l_fbdi_receipt_tbl(i).ATTRIBUTE19;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).ATTRIBUTE20                       :=l_fbdi_receipt_tbl(i).ATTRIBUTE20;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).ATTRIBUTE_NUMBER1                 :=l_fbdi_receipt_tbl(i).ATTRIBUTE_NUMBER1;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).ATTRIBUTE_NUMBER2                 :=l_fbdi_receipt_tbl(i).ATTRIBUTE_NUMBER2;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).ATTRIBUTE_NUMBER3                 :=l_fbdi_receipt_tbl(i).ATTRIBUTE_NUMBER3;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).ATTRIBUTE_NUMBER4                 :=l_fbdi_receipt_tbl(i).ATTRIBUTE_NUMBER4;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).ATTRIBUTE_NUMBER5                 :=l_fbdi_receipt_tbl(i).ATTRIBUTE_NUMBER5;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).ATTRIBUTE_NUMBER6                 :=l_fbdi_receipt_tbl(i).ATTRIBUTE_NUMBER6;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).ATTRIBUTE_NUMBER7                 :=l_fbdi_receipt_tbl(i).ATTRIBUTE_NUMBER7;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).ATTRIBUTE_NUMBER8                 :=l_fbdi_receipt_tbl(i).ATTRIBUTE_NUMBER8;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).ATTRIBUTE_NUMBER9                 :=l_fbdi_receipt_tbl(i).ATTRIBUTE_NUMBER9;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).ATTRIBUTE_NUMBER10                :=l_fbdi_receipt_tbl(i).ATTRIBUTE_NUMBER10;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).ATTRIBUTE_DATE1                   :=l_fbdi_receipt_tbl(i).ATTRIBUTE_DATE1;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).ATTRIBUTE_DATE2                   :=l_fbdi_receipt_tbl(i).ATTRIBUTE_DATE2;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).ATTRIBUTE_DATE3                   :=l_fbdi_receipt_tbl(i).ATTRIBUTE_DATE3;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).ATTRIBUTE_DATE4                   :=l_fbdi_receipt_tbl(i).ATTRIBUTE_DATE4;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).ATTRIBUTE_DATE5                   :=l_fbdi_receipt_tbl(i).ATTRIBUTE_DATE5;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).ATTRIBUTE_TIMESTAMP1              :=l_fbdi_receipt_tbl(i).ATTRIBUTE_TIMESTAMP1;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).ATTRIBUTE_TIMESTAMP2              :=l_fbdi_receipt_tbl(i).ATTRIBUTE_TIMESTAMP2;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).ATTRIBUTE_TIMESTAMP3              :=l_fbdi_receipt_tbl(i).ATTRIBUTE_TIMESTAMP3;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).ATTRIBUTE_TIMESTAMP4              :=l_fbdi_receipt_tbl(i).ATTRIBUTE_TIMESTAMP4;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).ATTRIBUTE_TIMESTAMP5              :=l_fbdi_receipt_tbl(i).ATTRIBUTE_TIMESTAMP5;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).GL_Date                           :=l_fbdi_receipt_tbl(i).GL_Date;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Receipt_Header_ID                 :=l_fbdi_receipt_tbl(i).Receipt_Header_ID;
			p_receipt_headers_out(p_receipt_headers_out.COUNT).Ext_Sys_Trans_Ref                 :=l_fbdi_receipt_tbl(i).Ext_Sys_Trans_Ref;
        END LOOP;
    END IF;
    p_status := 'S';
    p_message := 'Receipt Headers FBDI generated successfully';

EXCEPTION WHEN OTHERS
    THEN
        p_status := 'ERROR';
        p_message := 'Error in getting FBDI data for Receipt headers: '||SQLERRM;

END;

/**********************************************************************************
     Name              : getLinesFBDIData
     Purpose           : Get FBDI data for Requisition Lines
     ************************************************************************************/

PROCEDURE getLinesFBDIData (p_flow_id IN VARCHAR2, p_start_index IN NUMBER, p_end_index IN NUMBER, p_receipt_lines_out OUT AWC_PO_RECEIPT_LINE_TYPE_TBL, p_status OUT VARCHAR2, p_message OUT VARCHAR2)
AS

CURSOR c_lines
IS
    Select 
		Interface_Line_Number,
		Transaction_Type,
		Auto_Transact_Code,
		Transaction_Date,
		Source_Document_Code,
		Receipt_Source_Code,
		Header_Interface_Number,
		Parent_Transaction_ID,
		Parent_Interface_Line_Number,
		Organization_Code,
		Item_Number,
		Item_Description,
		Item_Revision,
		Document_Number,
		Document_Line_Number,
		Document_Schedule_Number,
		Document_Distribution_Number,
		Business_Unit,
		Shipment_Number,
		Expected_Receipt_Date,
		Subinventory,
		Locator,
		Quantity,
		UOM,
		Primary_Quantity,
		Primary_UOM,
		Secondary_Quantity,
		Secondary_UOM,
		Supplier_Name,
		Supplier_Number,
		Supplier_Site_Code,
		Customer_Name,
		Customer_Number,
		Customer_Account_Number,
		Ship_To_Location_Code,
		Location_Code,
		Reason_Name,
		Deliver_to_Person_Name,
		Deliver_to_Location_Code,
		Receipt_Exception_Flag,
		Routing_Header_ID,
		Destination_Type_Code,
		Interface_Source_Code,
		Interface_Source_Line_ID,
		Amount,
		Currency_Code,
		Currency_Conversion_Type,
		Currency_Conversion_Rate,
		Currency_Conversion_Date,
		Inspection_Status_Code,
		Inspection_Quality_Code,
		From_Organization_Code,
		From_Subinventory,
		From_Locator,
		Carrier_Name,
		Bill_of_Lading,
		Packing_Slip,
		Shipped_Date,
		Number_of_Containers,
		Waybill,
		RMA_Reference,
		Comments,
		Truck_Number,
		Container_Number,
		Substitute_Item_Number,
		Notice_Unit_Price,
		Item_Category,
		Intransit_Owning_Organization_Code,
		Routing_Name,
		Barcode_Label,
		Country_of_Origin_Code,
		Create_Debit_Memo_Flag,
		Source_Packing_Unit,
		Transfer_Packing_Unit,
		Packing_Unit_Group_Number,
		ASN_Line_Number,
		Employee_Name,
		Source_Transaction_Number,
		Parent_Source_Transaction_Number,
		Parent_Interface_Transaction_Id,
		Matching_Basis,
		Receipt_Advice_Logistics_Cust_Party_Name,
		Receipt_Advice_Doc_Number,
		Receipt_Advice_Doc_Line_Number,
		Receipt_Advice_Notes_to_Receiver,
		Receipt_Advice_Vendor_Site_Name,
		Attribute_Category,
		ATTRIBUTE1,
		ATTRIBUTE2,
		ATTRIBUTE3,
		ATTRIBUTE4,
		ATTRIBUTE5,
		ATTRIBUTE6,
		ATTRIBUTE7,
		ATTRIBUTE8,
		ATTRIBUTE9,
		ATTRIBUTE10,
		ATTRIBUTE11,
		ATTRIBUTE12,
		ATTRIBUTE13,
		ATTRIBUTE14,
		ATTRIBUTE15,
		ATTRIBUTE16,
		ATTRIBUTE17,
		ATTRIBUTE18,
		ATTRIBUTE19,
		ATTRIBUTE20,
		ATTRIBUTE_NUMBER1,
		ATTRIBUTE_NUMBER2,
		ATTRIBUTE_NUMBER3,
		ATTRIBUTE_NUMBER4,
		ATTRIBUTE_NUMBER5,
		ATTRIBUTE_NUMBER6,
		ATTRIBUTE_NUMBER7,
		ATTRIBUTE_NUMBER8,
		ATTRIBUTE_NUMBER9,
		ATTRIBUTE_NUMBER10,
		ATTRIBUTE_DATE1,
		ATTRIBUTE_DATE2,
		ATTRIBUTE_DATE3,
		ATTRIBUTE_DATE4,
		ATTRIBUTE_DATE5,
		ATTRIBUTE_TIMESTAMP1,
		ATTRIBUTE_TIMESTAMP2,
		ATTRIBUTE_TIMESTAMP3,
		ATTRIBUTE_TIMESTAMP4,
		ATTRIBUTE_TIMESTAMP5,
		Consigned_Flag,
		Sold_to_Legal_Entity,
		Consumed_Quantity,
		Default_Taxation_Country,
		Trx_Business_Category,
		Document_Fiscal_Classification,
		User_Defined_Fisc_Class,
		Product_Fisc_Classification,
		Intended_Use,
		Product_Category,
		Tax_Classification_Code,
		Product_Type,
		First_Party_Number,
		Third_Party_Number,
		Tax_Invoice_Number,
		Tax_Invoice_Date,
		Final_Discharge_Location_Code,
		Assessable_Value,
		Physical_Return_Required,
		External_Packing_Unit,
		E_Way_Bill,
		E_Way_Bill_Date,
		Recall_Notice_Nbr,
		Recall_Notice_Line_Nbr,
		Ext_Sys_Trans_Ref

    from AWC_PO_RECEIPT_LINE_TBL
    where flow_id = p_flow_id
    and rec_id >= p_start_index
    and rec_id <= p_end_index
    and status is null
    order by rec_id;

    TYPE l_fbdi_receipt_data IS TABLE OF c_lines%ROWTYPE
    INDEX BY PLS_INTEGER;

    l_fbdi_receipt_tbl l_fbdi_receipt_data;

BEGIN

    p_status := NULL;
    p_message := NULL;

    OPEN c_lines;
    FETCH c_lines BULK COLLECT INTO l_fbdi_receipt_tbl;
    CLOSE c_lines;

    IF l_fbdi_receipt_tbl.COUNT > 0
    THEN
        p_receipt_lines_out := AWC_PO_RECEIPT_LINE_TYPE_TBL();

        FOR i IN 1..l_fbdi_receipt_tbl.COUNT
        LOOP
            p_receipt_lines_out.EXTEND;

            p_receipt_lines_out(p_receipt_lines_out.COUNT) := AWC_PO_RECEIPT_LINE_TYPE(null, null, null, null, null, null, null, null, null, null,
																					   null, null, null, null, null, null, null, null, null, null,
																					   null, null, null, null, null, null, null, null, null, null,
                                                                                       null, null, null, null, null, null, null, null, null, null,
                                                                                       null, null, null, null, null, null, null, null, null, null,
                                                                                       null, null, null, null, null, null, null, null, null, null,
                                                                                       null, null, null, null, null, null, null, null, null, null,
                                                                                       null, null, null, null, null, null, null, null, null, null,
                                                                                       null, null, null, null, null, null, null, null, null, null,
                                                                                       null, null, null, null, null, null, null, null, null, null,
                                                                                       null, null, null, null, null, null, null, null, null, null,
                                                                                       null, null, null, null, null, null, null, null, null, null,
																					   null, null, null, null, null, null, null, null, null, null,
																					   null, null, null, null, null, null, null, null, null, null,
																					   null, null, null, null, null, null, null, null, null, null,
																					   null, null, null, null, null, null, null, null, null, null,
                                                                                       null, null, null, null,null);
			--p_receipt_lines_out(p_receipt_lines_out.COUNT).REQUESTED_SHIP_DATE       	:=	to_char(to_timestamp(SUBSTR(l_fbdi_receipt_tbl(i).REQUESTED_SHIP_DATE, 0, INSTR(l_fbdi_receipt_tbl(i).REQUESTED_SHIP_DATE, '.')-1), 'YYYY-MM-DD HH24:MI:SS'), 'YYYY-MM-DD')       	;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Interface_Line_Number                           :=l_fbdi_receipt_tbl(i).Interface_Line_Number;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Transaction_Type                                :=l_fbdi_receipt_tbl(i).Transaction_Type;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Auto_Transact_Code                              :=l_fbdi_receipt_tbl(i).Auto_Transact_Code;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Transaction_Date                                :=l_fbdi_receipt_tbl(i).Transaction_Date;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Source_Document_Code                            :=l_fbdi_receipt_tbl(i).Source_Document_Code;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Receipt_Source_Code                             :=l_fbdi_receipt_tbl(i).Receipt_Source_Code;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Header_Interface_Number                         :=l_fbdi_receipt_tbl(i).Header_Interface_Number;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Parent_Transaction_ID                           :=l_fbdi_receipt_tbl(i).Parent_Transaction_ID;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Parent_Interface_Line_Number                    :=l_fbdi_receipt_tbl(i).Parent_Interface_Line_Number;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Organization_Code                               :=l_fbdi_receipt_tbl(i).Organization_Code;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Item_Number                                     :=l_fbdi_receipt_tbl(i).Item_Number;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Item_Description                                :=l_fbdi_receipt_tbl(i).Item_Description;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Item_Revision                                   :=l_fbdi_receipt_tbl(i).Item_Revision;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Document_Number                                 :=l_fbdi_receipt_tbl(i).Document_Number;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Document_Line_Number                            :=l_fbdi_receipt_tbl(i).Document_Line_Number;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Document_Schedule_Number                        :=l_fbdi_receipt_tbl(i).Document_Schedule_Number;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Document_Distribution_Number                    :=l_fbdi_receipt_tbl(i).Document_Distribution_Number;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Business_Unit                                   :=l_fbdi_receipt_tbl(i).Business_Unit;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Shipment_Number                                 :=l_fbdi_receipt_tbl(i).Shipment_Number;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Expected_Receipt_Date                           :=l_fbdi_receipt_tbl(i).Expected_Receipt_Date;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Subinventory                                    :=l_fbdi_receipt_tbl(i).Subinventory;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Locator                                         :=l_fbdi_receipt_tbl(i).Locator;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Quantity                                        :=l_fbdi_receipt_tbl(i).Quantity;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).UOM                                             :=l_fbdi_receipt_tbl(i).UOM;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Primary_Quantity                                :=l_fbdi_receipt_tbl(i).Primary_Quantity;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Primary_UOM                                     :=l_fbdi_receipt_tbl(i).Primary_UOM;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Secondary_Quantity                              :=l_fbdi_receipt_tbl(i).Secondary_Quantity;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Secondary_UOM                                   :=l_fbdi_receipt_tbl(i).Secondary_UOM;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Supplier_Name                                   :=l_fbdi_receipt_tbl(i).Supplier_Name;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Supplier_Number                                 :=l_fbdi_receipt_tbl(i).Supplier_Number;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Supplier_Site_Code                              :=l_fbdi_receipt_tbl(i).Supplier_Site_Code;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Customer_Name                                   :=l_fbdi_receipt_tbl(i).Customer_Name;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Customer_Number                                 :=l_fbdi_receipt_tbl(i).Customer_Number;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Customer_Account_Number                         :=l_fbdi_receipt_tbl(i).Customer_Account_Number;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Ship_To_Location_Code                           :=l_fbdi_receipt_tbl(i).Ship_To_Location_Code;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Location_Code                                   :=l_fbdi_receipt_tbl(i).Location_Code;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Reason_Name                                     :=l_fbdi_receipt_tbl(i).Reason_Name;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Deliver_to_Person_Name                          :=l_fbdi_receipt_tbl(i).Deliver_to_Person_Name;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Deliver_to_Location_Code                        :=l_fbdi_receipt_tbl(i).Deliver_to_Location_Code;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Receipt_Exception_Flag                          :=l_fbdi_receipt_tbl(i).Receipt_Exception_Flag;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Routing_Header_ID                               :=l_fbdi_receipt_tbl(i).Routing_Header_ID;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Destination_Type_Code                           :=l_fbdi_receipt_tbl(i).Destination_Type_Code;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Interface_Source_Code                           :=l_fbdi_receipt_tbl(i).Interface_Source_Code;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Interface_Source_Line_ID                        :=l_fbdi_receipt_tbl(i).Interface_Source_Line_ID;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Amount                                          :=l_fbdi_receipt_tbl(i).Amount;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Currency_Code                                   :=l_fbdi_receipt_tbl(i).Currency_Code;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Currency_Conversion_Type                        :=l_fbdi_receipt_tbl(i).Currency_Conversion_Type;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Currency_Conversion_Rate                        :=l_fbdi_receipt_tbl(i).Currency_Conversion_Rate;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Currency_Conversion_Date                        :=l_fbdi_receipt_tbl(i).Currency_Conversion_Date;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Inspection_Status_Code                          :=l_fbdi_receipt_tbl(i).Inspection_Status_Code;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Inspection_Quality_Code                         :=l_fbdi_receipt_tbl(i).Inspection_Quality_Code;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).From_Organization_Code                          :=l_fbdi_receipt_tbl(i).From_Organization_Code;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).From_Subinventory                               :=l_fbdi_receipt_tbl(i).From_Subinventory;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).From_Locator                                    :=l_fbdi_receipt_tbl(i).From_Locator;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Carrier_Name                                    :=l_fbdi_receipt_tbl(i).Carrier_Name;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Bill_of_Lading                                  :=l_fbdi_receipt_tbl(i).Bill_of_Lading;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Packing_Slip                                    :=l_fbdi_receipt_tbl(i).Packing_Slip;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Shipped_Date                                    :=l_fbdi_receipt_tbl(i).Shipped_Date;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Number_of_Containers                            :=l_fbdi_receipt_tbl(i).Number_of_Containers;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Waybill                                         :=l_fbdi_receipt_tbl(i).Waybill;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).RMA_Reference                                   :=l_fbdi_receipt_tbl(i).RMA_Reference;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Comments                                        :=l_fbdi_receipt_tbl(i).Comments;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Truck_Number                                    :=l_fbdi_receipt_tbl(i).Truck_Number;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Container_Number                                :=l_fbdi_receipt_tbl(i).Container_Number;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Substitute_Item_Number                          :=l_fbdi_receipt_tbl(i).Substitute_Item_Number;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Notice_Unit_Price                               :=l_fbdi_receipt_tbl(i).Notice_Unit_Price;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Item_Category                                   :=l_fbdi_receipt_tbl(i).Item_Category;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Intransit_Owning_Organization_Code              :=l_fbdi_receipt_tbl(i).Intransit_Owning_Organization_Code;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Routing_Name                                    :=l_fbdi_receipt_tbl(i).Routing_Name;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Barcode_Label                                   :=l_fbdi_receipt_tbl(i).Barcode_Label;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Country_of_Origin_Code                          :=l_fbdi_receipt_tbl(i).Country_of_Origin_Code;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Create_Debit_Memo_Flag                          :=l_fbdi_receipt_tbl(i).Create_Debit_Memo_Flag;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Source_Packing_Unit                             :=l_fbdi_receipt_tbl(i).Source_Packing_Unit;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Transfer_Packing_Unit                           :=l_fbdi_receipt_tbl(i).Transfer_Packing_Unit;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Packing_Unit_Group_Number                       :=l_fbdi_receipt_tbl(i).Packing_Unit_Group_Number;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).ASN_Line_Number                                 :=l_fbdi_receipt_tbl(i).ASN_Line_Number;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Employee_Name                                   :=l_fbdi_receipt_tbl(i).Employee_Name;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Source_Transaction_Number                       :=l_fbdi_receipt_tbl(i).Source_Transaction_Number;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Parent_Source_Transaction_Number                :=l_fbdi_receipt_tbl(i).Parent_Source_Transaction_Number;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Parent_Interface_Transaction_Id                 :=l_fbdi_receipt_tbl(i).Parent_Interface_Transaction_Id;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Matching_Basis                                  :=l_fbdi_receipt_tbl(i).Matching_Basis;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Receipt_Advice_Logistics_Cust_Party_Name        :=l_fbdi_receipt_tbl(i).Receipt_Advice_Logistics_Cust_Party_Name;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Receipt_Advice_Doc_Number                       :=l_fbdi_receipt_tbl(i).Receipt_Advice_Doc_Number;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Receipt_Advice_Doc_Line_Number                  :=l_fbdi_receipt_tbl(i).Receipt_Advice_Doc_Line_Number;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Receipt_Advice_Notes_to_Receiver                :=l_fbdi_receipt_tbl(i).Receipt_Advice_Notes_to_Receiver;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Receipt_Advice_Vendor_Site_Name                 :=l_fbdi_receipt_tbl(i).Receipt_Advice_Vendor_Site_Name;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Attribute_Category                              :=l_fbdi_receipt_tbl(i).Attribute_Category;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).ATTRIBUTE1                                      :=l_fbdi_receipt_tbl(i).ATTRIBUTE1;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).ATTRIBUTE2                                      :=l_fbdi_receipt_tbl(i).ATTRIBUTE2;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).ATTRIBUTE3                                      :=l_fbdi_receipt_tbl(i).ATTRIBUTE3;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).ATTRIBUTE4                                      :=l_fbdi_receipt_tbl(i).ATTRIBUTE4;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).ATTRIBUTE5                                      :=l_fbdi_receipt_tbl(i).ATTRIBUTE5;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).ATTRIBUTE6                                      :=l_fbdi_receipt_tbl(i).ATTRIBUTE6;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).ATTRIBUTE7                                      :=l_fbdi_receipt_tbl(i).ATTRIBUTE7;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).ATTRIBUTE8                                      :=l_fbdi_receipt_tbl(i).ATTRIBUTE8;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).ATTRIBUTE9                                      :=l_fbdi_receipt_tbl(i).ATTRIBUTE9;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).ATTRIBUTE10                                     :=l_fbdi_receipt_tbl(i).ATTRIBUTE10;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).ATTRIBUTE11                                     :=l_fbdi_receipt_tbl(i).ATTRIBUTE11;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).ATTRIBUTE12                                     :=l_fbdi_receipt_tbl(i).ATTRIBUTE12;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).ATTRIBUTE13                                     :=l_fbdi_receipt_tbl(i).ATTRIBUTE13;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).ATTRIBUTE14                                     :=l_fbdi_receipt_tbl(i).ATTRIBUTE14;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).ATTRIBUTE15                                     :=l_fbdi_receipt_tbl(i).ATTRIBUTE15;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).ATTRIBUTE16                                     :=l_fbdi_receipt_tbl(i).ATTRIBUTE16;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).ATTRIBUTE17                                     :=l_fbdi_receipt_tbl(i).ATTRIBUTE17;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).ATTRIBUTE18                                     :=l_fbdi_receipt_tbl(i).ATTRIBUTE18;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).ATTRIBUTE19                                     :=l_fbdi_receipt_tbl(i).ATTRIBUTE19;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).ATTRIBUTE20                                     :=l_fbdi_receipt_tbl(i).ATTRIBUTE20;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).ATTRIBUTE_NUMBER1                               :=l_fbdi_receipt_tbl(i).ATTRIBUTE_NUMBER1;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).ATTRIBUTE_NUMBER2                               :=l_fbdi_receipt_tbl(i).ATTRIBUTE_NUMBER2;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).ATTRIBUTE_NUMBER3                               :=l_fbdi_receipt_tbl(i).ATTRIBUTE_NUMBER3;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).ATTRIBUTE_NUMBER4                               :=l_fbdi_receipt_tbl(i).ATTRIBUTE_NUMBER4;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).ATTRIBUTE_NUMBER5                               :=l_fbdi_receipt_tbl(i).ATTRIBUTE_NUMBER5;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).ATTRIBUTE_NUMBER6                               :=l_fbdi_receipt_tbl(i).ATTRIBUTE_NUMBER6;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).ATTRIBUTE_NUMBER7                               :=l_fbdi_receipt_tbl(i).ATTRIBUTE_NUMBER7;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).ATTRIBUTE_NUMBER8                               :=l_fbdi_receipt_tbl(i).ATTRIBUTE_NUMBER8;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).ATTRIBUTE_NUMBER9                               :=l_fbdi_receipt_tbl(i).ATTRIBUTE_NUMBER9;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).ATTRIBUTE_NUMBER10                              :=l_fbdi_receipt_tbl(i).ATTRIBUTE_NUMBER10;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).ATTRIBUTE_DATE1                                 :=l_fbdi_receipt_tbl(i).ATTRIBUTE_DATE1;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).ATTRIBUTE_DATE2                                 :=l_fbdi_receipt_tbl(i).ATTRIBUTE_DATE2;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).ATTRIBUTE_DATE3                                 :=l_fbdi_receipt_tbl(i).ATTRIBUTE_DATE3;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).ATTRIBUTE_DATE4                                 :=l_fbdi_receipt_tbl(i).ATTRIBUTE_DATE4;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).ATTRIBUTE_DATE5                                 :=l_fbdi_receipt_tbl(i).ATTRIBUTE_DATE5;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).ATTRIBUTE_TIMESTAMP1                            :=l_fbdi_receipt_tbl(i).ATTRIBUTE_TIMESTAMP1;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).ATTRIBUTE_TIMESTAMP2                            :=l_fbdi_receipt_tbl(i).ATTRIBUTE_TIMESTAMP2;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).ATTRIBUTE_TIMESTAMP3                            :=l_fbdi_receipt_tbl(i).ATTRIBUTE_TIMESTAMP3;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).ATTRIBUTE_TIMESTAMP4                            :=l_fbdi_receipt_tbl(i).ATTRIBUTE_TIMESTAMP4;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).ATTRIBUTE_TIMESTAMP5                            :=l_fbdi_receipt_tbl(i).ATTRIBUTE_TIMESTAMP5;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Consigned_Flag                                  :=l_fbdi_receipt_tbl(i).Consigned_Flag;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Sold_to_Legal_Entity                            :=l_fbdi_receipt_tbl(i).Sold_to_Legal_Entity;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Consumed_Quantity                               :=l_fbdi_receipt_tbl(i).Consumed_Quantity;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Default_Taxation_Country                        :=l_fbdi_receipt_tbl(i).Default_Taxation_Country;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Trx_Business_Category                           :=l_fbdi_receipt_tbl(i).Trx_Business_Category;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Document_Fiscal_Classification                  :=l_fbdi_receipt_tbl(i).Document_Fiscal_Classification;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).User_Defined_Fisc_Class                         :=l_fbdi_receipt_tbl(i).User_Defined_Fisc_Class;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Product_Fisc_Classification                     :=l_fbdi_receipt_tbl(i).Product_Fisc_Classification;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Intended_Use                                    :=l_fbdi_receipt_tbl(i).Intended_Use;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Product_Category                                :=l_fbdi_receipt_tbl(i).Product_Category;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Tax_Classification_Code                         :=l_fbdi_receipt_tbl(i).Tax_Classification_Code;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Product_Type                                    :=l_fbdi_receipt_tbl(i).Product_Type;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).First_Party_Number                              :=l_fbdi_receipt_tbl(i).First_Party_Number;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Third_Party_Number                              :=l_fbdi_receipt_tbl(i).Third_Party_Number;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Tax_Invoice_Number                              :=l_fbdi_receipt_tbl(i).Tax_Invoice_Number;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Tax_Invoice_Date                                :=l_fbdi_receipt_tbl(i).Tax_Invoice_Date;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Final_Discharge_Location_Code                   :=l_fbdi_receipt_tbl(i).Final_Discharge_Location_Code;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Assessable_Value                                :=l_fbdi_receipt_tbl(i).Assessable_Value;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Physical_Return_Required                        :=l_fbdi_receipt_tbl(i).Physical_Return_Required;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).External_Packing_Unit                           :=l_fbdi_receipt_tbl(i).External_Packing_Unit;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).E_Way_Bill                                      :=l_fbdi_receipt_tbl(i).E_Way_Bill;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).E_Way_Bill_Date                                 :=l_fbdi_receipt_tbl(i).E_Way_Bill_Date;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Recall_Notice_Nbr                               :=l_fbdi_receipt_tbl(i).Recall_Notice_Nbr;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Recall_Notice_Line_Nbr                          :=l_fbdi_receipt_tbl(i).Recall_Notice_Line_Nbr;
				p_receipt_lines_out(p_receipt_lines_out.COUNT).Ext_Sys_Trans_Ref                               :=l_fbdi_receipt_tbl(i).Ext_Sys_Trans_Ref;


        END LOOP;
    END IF;

    p_status := 'S';
    p_message := 'Receipt Lines FBDI generated successfully';

EXCEPTION WHEN OTHERS
    THEN
        p_status := 'ERROR';
        p_message := 'Error in getting FBDI data for Receipt Lines: '||SQLERRM;

END;

/**********************************************************************************
     Name              : getImportErrData
     Purpose           : Get Import Error Records
     ************************************************************************************/

PROCEDURE getImportErrData (p_import_source IN VARCHAR2, p_FLOW_ID IN VARCHAR2, p_LOAD_REQUEST_ID IN VARCHAR2, p_xref_in IN AWC_PO_RECEIPT_IMPORT_ERRORS_TYPE_TBL, p_status OUT VARCHAR2, p_message OUT VARCHAR2)
AS

BEGIN

p_status := NULL;
    p_message := NULL;

        FORALL i IN p_xref_in.FIRST .. p_xref_in.LAST SAVE EXCEPTIONS
            -- Inserting input data from file into staging table
            Insert into AWC_PO_RECEIPT_IMPORT_ERRORS (FLOW_ID,
                                                        LOAD_REQUEST_ID,
														IMPORT_SOURCE,
														HEADER_INTERFACE_NUMBER,
														ERROR_TYPE,
														ERROR_MESSAGE)
                                         values (p_FLOW_ID, p_LOAD_REQUEST_ID,
													p_import_source,
													p_xref_in(i).HEADER_INTERFACE_NUMBER,
													p_xref_in(i).ERROR_TYPE,
													p_xref_in(i).ERROR_MESSAGE );

    COMMIT;

    -- Header Rollup Error from Import Errors
    Update AWC_DUMMY_TBL_1 A
    set A.status = 'E',
     A.ERROR_TYPE = 'Import Errors',
     A.message = A.message||' ' || (select B.ERROR_MESSAGE from AWC_PO_RECEIPT_IMPORT_ERRORS B WHERE A.SOURCE = B.IMPORT_SOURCE AND A.HEADER_INTERFACE_NUMBER = B.HEADER_INTERFACE_NUMBER AND B.LOAD_REQUEST_ID = p_LOAD_REQUEST_ID)
   WHERE A.flow_id = p_FLOW_ID
   and A.SOURCE = p_import_source
	and exists (select 'x' from AWC_PO_RECEIPT_IMPORT_ERRORS B
                        WHERE A.SOURCE = B.IMPORT_SOURCE 
                          AND A.HEADER_INTERFACE_NUMBER = B.HEADER_INTERFACE_NUMBER
						  AND B.LOAD_REQUEST_ID = p_LOAD_REQUEST_ID);

    --Mark Base Table with Error Updates
   Update AWC_DUMMY_TBL_2 A
    set A.status = 'E',
         (A.ERROR_TYPE ,A.message) = (select B.ERROR_TYPE, B.message from AWC_DUMMY_TBL_1 B WHERE A.FLOW_ID = B.FLOW_ID AND A.PO_XREF_ID = B.PO_XREF_ID AND B.status = 'E' AND B.ERROR_TYPE = 'Import Errors')
   WHERE A.flow_id = p_flow_id
	and exists (select 'x' from AWC_DUMMY_TBL_1 B WHERE A.FLOW_ID = B.FLOW_ID AND A.PO_XREF_ID = B.PO_XREF_ID AND B.status = 'E' AND B.ERROR_TYPE = 'Import Errors' );

    p_status := 'SUCCESS';
    p_message := 'data loded successfully';

EXCEPTION WHEN OTHERS
    THEN
        p_status := 'ERROR';
        p_message := 'Error in getting data: '||SQLERRM;

END;

/**********************************************************************************
     Name              : validateXRefData
     Purpose           : Validations for Requisition Headers, Lines & Distributions
     ************************************************************************************/

PROCEDURE validateXRefData (p_flow_id IN VARCHAR2, p_status OUT VARCHAR2, p_message OUT VARCHAR2)
AS

BEGIN

    p_status := NULL;
    p_message := NULL;

    -- PO Number not found in Oracle 
    Update AWC_DUMMY_TBL_1
    set status = 'E',
         message = message||' Purchase Order Missing in Oracle' , ERROR_TYPE = 'Validation Error'
   WHERE SUPPLIER_NAME IS NULL
	AND SUPPLIER_NUM IS NULL
	AND SUPPLIER_SITE_CODE IS NULL
    and flow_id = p_flow_id;

    -- PO Number blank in INPUT file 
    Update AWC_PO_RECEIPT_LINE_TBL
    set status = 'E',
         message = message||' Purchase Order Blank in input file', ERROR_TYPE = 'Validation Error'
   WHERE DOCUMENT_NUMBER IS NULL
    and flow_id = p_flow_id;

    -- Employee Mapping not Found  
/*    Update AWC_PO_RECEIPT_LINE_TBL A
    set A.status = 'E',
         A.message = A.message||' USERID Mapping not Found', ERROR_TYPE = 'Validation Error'
   WHERE A.Employee_Name IS NULL
    and A.flow_id = p_flow_id
	and exists (select 'x' from AWC_DUMMY_TBL_2 B WHERE A.FLOW_ID = B.FLOW_ID AND A.PO_XREF_ID = B.PO_XREF_ID AND USERID IS NOT NULL );

    -- Employee Blank in File
    Update AWC_PO_RECEIPT_LINE_TBL A
    set A.status = 'E',
         A.message = A.message||' USERID Missing in Input File', ERROR_TYPE = 'Validation Error'
   WHERE A.Employee_Name IS NULL
    and A.flow_id = p_flow_id
	and exists (select 'x' from AWC_DUMMY_TBL_2 B WHERE A.FLOW_ID = B.FLOW_ID AND A.PO_XREF_ID = B.PO_XREF_ID AND USERID IS NULL );
*/
    -- Header Rollup Error from Line Errors
    Update AWC_DUMMY_TBL_1 A
    set A.status = 'E',
     A.ERROR_TYPE = 'Validation Error',
     A.message = A.message||' ' || (select B.message from AWC_PO_RECEIPT_LINE_TBL B WHERE A.FLOW_ID = B.FLOW_ID AND A.PO_XREF_ID = B.PO_XREF_ID AND B.status = 'E')
   WHERE A.flow_id = p_flow_id
	and exists (select 'x' from AWC_PO_RECEIPT_LINE_TBL B WHERE A.FLOW_ID = B.FLOW_ID AND A.PO_XREF_ID = B.PO_XREF_ID AND B.status = 'E' );

   --Mark line rows in error for Header Error Validation 
    Update AWC_PO_RECEIPT_LINE_TBL A
    set A.status = 'E',
     A.ERROR_TYPE = 'Validation Error',
     A.message = 'Header Validation failure'
   WHERE A.flow_id = p_flow_id
   and A.status <> 'E'
	and exists (select 'x' from AWC_DUMMY_TBL_1 B WHERE A.FLOW_ID = B.FLOW_ID AND A.PO_XREF_ID = B.PO_XREF_ID AND B.status = 'E' ); 

  --Mark Base Table with Error Updates
   Update AWC_DUMMY_TBL_2 A
    set A.status = 'E',
         (A.ERROR_TYPE ,A.message) = (select B.ERROR_TYPE, B.message from AWC_DUMMY_TBL_1 B WHERE A.FLOW_ID = B.FLOW_ID AND A.PO_XREF_ID = B.PO_XREF_ID AND B.status = 'E')
   WHERE A.flow_id = p_flow_id
	and exists (select 'x' from AWC_DUMMY_TBL_1 B WHERE A.FLOW_ID = B.FLOW_ID AND A.PO_XREF_ID = B.PO_XREF_ID AND B.status = 'E' );


    COMMIT;

    EXCEPTION WHEN OTHERS
    THEN
        p_status := 'ERROR';
        p_message := 'Error in validating requisition data: '||SQLERRM;

END;

/**********************************************************************************
     Name              : getValidationErrData
     Purpose           : Get Validation Error Records
     ************************************************************************************/

PROCEDURE getValidationErrData (p_flow_id IN VARCHAR2, p_xref_out OUT AWC_PO_RECEIPT_INPUT_TBL, p_status OUT VARCHAR2, p_message OUT VARCHAR2)
AS

BEGIN

    Select AWC_PO_RECEIPT_INPUT_TYPE(RS.PO_XREF_ID      ,
                                    RS.FLOW_ID         ,
                                    RS.FILE_NAME       ,
                                    RS.SENTLOC         ,
                                    RS.BILLOFLADING    ,
                                    RS.PALLET          ,
                                    RS.RECNO           ,
                                    RS.TYPE            ,
                                    RS.ACTION          ,
                                    RS.UPLDDATE        ,
                                    RS.BUYENT          ,
                                    RS.PONUM           ,
                                    RS.POLINE          ,
                                    RS.POPALLET        ,
                                    RS.POBLNKTREL      ,
                                    RS.POPACKSLIP      ,
                                    RS.POITEMCTLG      ,
                                    RS.POITEM          ,
                                    RS.POUOM           ,
                                    RS.PODELDATE       ,
                                    RS.POQTYR          ,
                                    RS.POCARR          ,
                                    RS.POORIG          ,
                                    RS.POBOL           ,
                                    RS.POWEIGHT        ,
                                    RS.PONOTES         ,
                                    RS.ULDT            ,
                                    RS.PROCESSED       ,
                                    RS.COMPLETE        ,
                                    RS.USERID          ,
                                    RS.PUTAWAYHOLD     ,
                                    RS.RECEIVEDDATE    ,
                                    RS.SHIPPEDDATE     ,
                                    RS.CREATION_DATE   ,
                                    RS.CREATED_BY      ,
                                    RS.LAST_UPDATE_DATE,
                                    RS.LAST_UPDATED_BY ,
                                    'Validation Error'      ,
                                    RH.STATUS,
									RH.MESSAGE 
									)
    BULK COLLECT INTO p_xref_out
    from AWC_DUMMY_TBL_1 RH,AWC_DUMMY_TBL_2 RS
		where RH.FLOW_ID = RS.FLOW_ID
		  and RH.PO_XREF_ID = RS.PO_XREF_ID
		  AND RH.flow_id = p_flow_id
		  and RH.status = 'E';

    p_status := 'SUCCESS';
    p_message := 'Data retrieved successfully';


EXCEPTION WHEN OTHERS
    THEN
        p_status := 'ERROR';
        p_message := 'Error in getting data: '||SQLERRM;

END;


/**********************************************************************************
     Name              : getImportErrData_SFTP
     Purpose           : Get Validation Error Records
     ************************************************************************************/

PROCEDURE getImportErrData_SFTP (p_import_source IN VARCHAR2, p_LOAD_REQUEST_ID IN VARCHAR2 , p_flow_id IN VARCHAR2, p_xref_out OUT AWC_PO_RECEIPT_INPUT_TBL, p_status OUT VARCHAR2, p_message OUT VARCHAR2)
AS

BEGIN

    Select AWC_PO_RECEIPT_INPUT_TYPE(RS.PO_XREF_ID      ,
                                    RS.FLOW_ID         ,
                                    RS.FILE_NAME       ,
                                    RS.SENTLOC         ,
                                    RS.BILLOFLADING    ,
                                    RS.PALLET          ,
                                    RS.RECNO           ,
                                    RS.TYPE            ,
                                    RS.ACTION          ,
                                    RS.UPLDDATE        ,
                                    RS.BUYENT          ,
                                    RS.PONUM           ,
                                    RS.POLINE          ,
                                    RS.POPALLET        ,
                                    RS.POBLNKTREL      ,
                                    RS.POPACKSLIP      ,
                                    RS.POITEMCTLG      ,
                                    RS.POITEM          ,
                                    RS.POUOM           ,
                                    RS.PODELDATE       ,
                                    RS.POQTYR          ,
                                    RS.POCARR          ,
                                    RS.POORIG          ,
                                    RS.POBOL           ,
                                    RS.POWEIGHT        ,
                                    RS.PONOTES         ,
                                    RS.ULDT            ,
                                    RS.PROCESSED       ,
                                    RS.COMPLETE        ,
                                    RS.USERID          ,
                                    RS.PUTAWAYHOLD     ,
                                    RS.RECEIVEDDATE    ,
                                    RS.SHIPPEDDATE     ,
                                    RS.CREATION_DATE   ,
                                    RS.CREATED_BY      ,
                                    RS.LAST_UPDATE_DATE,
                                    RS.LAST_UPDATED_BY ,
                                    'Import Error' ,
                                    'E',
									ER.ERROR_MESSAGE 
									)
    BULK COLLECT INTO p_xref_out
    from AWC_PO_RECEIPT_IMPORT_ERRORS ER, AWC_DUMMY_TBL_1 RH, AWC_DUMMY_TBL_2 RS 
		where ER.HEADER_INTERFACE_NUMBER = RH.HEADER_INTERFACE_NUMBER
 		  and ER.import_source = p_import_source 
		  AND ER.LOAD_REQUEST_ID = p_LOAD_REQUEST_ID 
		  and RH.PO_XREF_ID = RS.PO_XREF_ID
		  AND RH.FLOW_ID = RS.FLOW_ID
 		  AND RH.flow_id = p_flow_id;

    p_status := 'SUCCESS';
    p_message := 'Data retrieved successfully';


EXCEPTION WHEN OTHERS
    THEN
        p_status := 'ERROR';
        p_message := 'Error in getting data: '||SQLERRM;

END;


END AWC_DUMMY_RECEIPTS_PKG;

/
