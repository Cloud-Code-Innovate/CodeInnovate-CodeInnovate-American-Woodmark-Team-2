--------------------------------------------------------
--  DDL for Package AWC_PO_RECEIPTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "AWC_PO_RECEIPTS_PKG" AS
/****************************************************************************
    *
    * NAME:        AWC_POR_RECEIPTS_PKG.pkb
    * PURPOSE:     Custom package for Receipts Inbound
    *
    * REVISIONS
    *
    * VERSION   DATE         AUTHOR(S)            DESCRIPTION
    * -------   ----------   --------------       ------------------------ 
    * 1.0       04-MAR-2021  Baljeet Oberoi      Initial version
   /*****************************AWC_POR_REQUISITION_PKG Body**********************************************/

   /**********************************************************************************
     Name              : checkDuplicatFile
     Purpose           : Check if file name is duplicate
     ************************************************************************************/

PROCEDURE checkDuplicatFile (p_file_name IN VARCHAR2, p_status OUT VARCHAR2, p_message OUT VARCHAR2);

  /**********************************************************************************
     Name              : createPoXRefData
     Purpose           : Load input data to staging table
     ************************************************************************************/

PROCEDURE createPoXRefData (p_xref_inputs IN AWC_PO_RECEIPT_INPUT_TBL , p_status OUT VARCHAR2, p_message OUT VARCHAR2);


   /**********************************************************************************
     Name              : poSupplierSyncXRefData
     Purpose           : Load PO Supplier data to sync table
     ************************************************************************************/

PROCEDURE poSupplierSyncXRefData (p_xref_inputs IN AWC_PO_SUP_INPUT_TBL, p_status OUT VARCHAR2, p_message OUT VARCHAR2);

/**********************************************************************************
     Name              : ReceiptHeaderLoadStage
     Purpose           : Generate data for Receipt Header
     ************************************************************************************/

PROCEDURE ReceiptHeaderLoadStage (p_flow_id IN VARCHAR2, p_user IN VARCHAR, p_status OUT VARCHAR2, p_message OUT VARCHAR2);

/**********************************************************************************
     Name              : ReceiptLineLoadStage
     Purpose           : Generate data for Receipt Header
     ************************************************************************************/

PROCEDURE ReceiptLineLoadStage (p_flow_id IN VARCHAR2, p_user IN VARCHAR, p_status OUT VARCHAR2, p_message OUT VARCHAR2);


     /**********************************************************************************
     Name              : USERIDEMPLSyncXRefData
     Purpose           : Load USER ID and Employee Name Legacy Mapping to sync table
     ************************************************************************************/

PROCEDURE USERIDEMPLSyncXRefData (p_xref_inputs IN AWC_RECEIPT_EMP_TYPE_TBL, p_status OUT VARCHAR2, p_message OUT VARCHAR2);

/**********************************************************************************
     Name              : getHdrsFBDIData
     Purpose           : Get FBDI data for Requisition Headers
     ************************************************************************************/

PROCEDURE getHdrsFBDIData (p_flow_id IN VARCHAR2, p_start_index IN NUMBER, p_end_index IN NUMBER, p_receipt_headers_out OUT AWC_PO_RECEIPT_HDR_TYPE_TBL, p_status OUT VARCHAR2, p_message OUT VARCHAR2);

/**********************************************************************************
     Name              : getLinesFBDIData
     Purpose           : Get FBDI data for Requisition Lines
     ************************************************************************************/

PROCEDURE getLinesFBDIData (p_flow_id IN VARCHAR2, p_start_index IN NUMBER, p_end_index IN NUMBER, p_receipt_lines_out OUT AWC_PO_RECEIPT_LINE_TYPE_TBL, p_status OUT VARCHAR2, p_message OUT VARCHAR2);

/**********************************************************************************
     Name              : getImportErrData
     Purpose           : Get Import Error Records
     ************************************************************************************/

PROCEDURE getImportErrData (p_import_source IN VARCHAR2, p_FLOW_ID IN VARCHAR2, p_LOAD_REQUEST_ID IN VARCHAR2, p_xref_in IN AWC_PO_RECEIPT_IMPORT_ERRORS_TYPE_TBL, p_status OUT VARCHAR2, p_message OUT VARCHAR2);


/**********************************************************************************
     Name              : validateXRefData
     Purpose           : Validations for Requisition Headers, Lines & Distributions
     ************************************************************************************/

PROCEDURE validateXRefData (p_flow_id IN VARCHAR2, p_status OUT VARCHAR2, p_message OUT VARCHAR2);

/**********************************************************************************
     Name              : getValidationErrData
     Purpose           : Get Validation Error Records
     ************************************************************************************/

PROCEDURE getValidationErrData (p_flow_id IN VARCHAR2, p_xref_out OUT AWC_PO_RECEIPT_INPUT_TBL, p_status OUT VARCHAR2, p_message OUT VARCHAR2);

/**********************************************************************************
     Name              : getImportErrData_SFTP
     Purpose           : Get Validation Error Records
     ************************************************************************************/

PROCEDURE getImportErrData_SFTP (p_import_source IN VARCHAR2, p_LOAD_REQUEST_ID IN VARCHAR2 , p_flow_id IN VARCHAR2, p_xref_out OUT AWC_PO_RECEIPT_INPUT_TBL, p_status OUT VARCHAR2, p_message OUT VARCHAR2);

END AWC_PO_RECEIPTS_PKG;

/
