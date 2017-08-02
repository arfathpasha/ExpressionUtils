/*
A KBase module: ExpressionUtils
*/

/**
    A KBase module: ExpressionUtils

    This module is intended for use by Assemblers to upload RNASeq Expression files
    (gtf, fpkm and ctab). This module generates the ctab files and tpm data if they are absent.
    The expression files are uploaded as a single compressed file.This module also generates
    expression levels and tpm expression levels from the input files and saves them in the
    workspace object. Once uploaded, the expression files can be downloaded onto an output directory.
**/

module ExpressionUtils {

   /* A boolean - 0 for false, 1 for true.
       @range (0, 1)
   */

    typedef int boolean;

   /**    Required input parameters for uploading a reads expression data

        string   destination_ref        -   object reference of expression data.
                                            The object ref is 'ws_name_or_id/obj_name_or_id'
                                            where ws_name_or_id is the workspace name or id
                                            and obj_name_or_id is the object name or id
                                            
        string   source_dir             -   directory with the files to be uploaded
        string   alignment_ref          -   alignment workspace object reference
    **/

    typedef structure {

        string   destination_ref;
        string   source_dir;
        string   alignment_ref;

        string   genome_ref;            /*  Optional  - if alignment_ref does not contain a genome_ref
                                            this input needs to be given   */
        string   annotation_id;         /*  Optional  - annotation ref of the genome object */

        string   bam_file_path;         /*  Optional  - Used to create ctab files if they are absent in the
                                            source_dir. If this field is not provided for ctab files generation,
                                            then the bam file is downloaded from the input alignment_ref */

        int      data_quality_level;    /*  Optional */
        float    original_median;       /*  Optional */

        string   description;           /*  Optional */
        string   platform;              /*  Optional */
        string   source;                /*  Optional */
        string   external_source_date;	/*  Optional */
        string   processing_comments;	/*  Optional */

    }  UploadExpressionParams;

    /**     Output from upload expression    **/

    typedef structure {
        string   obj_ref;
     }  UploadExpressionOutput;

    /**  Uploads the expression  **/

    funcdef  upload_expression(UploadExpressionParams params)
                                   returns (UploadExpressionOutput)
                                   authentication required;
    /**
        Required input parameters for downloading expression
        string source_ref 	-       object reference of expression source. The
                                    object ref is 'ws_name_or_id/obj_name_or_id'
                                    where ws_name_or_id is the workspace name or id
                                    and obj_name_or_id is the object name or id
    **/

    typedef structure {
        string      source_ref;
    } DownloadExpressionParams;

    /**  The output of the download method.  **/

    typedef structure {
        string    destination_dir;      /* directory containing all the downloaded files  */
    } DownloadExpressionOutput;

    /** Downloads expression **/

    funcdef download_expression(DownloadExpressionParams params)
                       returns (DownloadExpressionOutput)
                       authentication required;

    /**
        Required input parameters for exporting expression

        string   source_ref 	-   object reference of expression source. The
                                    object ref is 'ws_name_or_id/obj_name_or_id'
                                    where ws_name_or_id is the workspace name or id
                                    and obj_name_or_id is the object name or id
     **/

    typedef structure {
        string  source_ref;   /* workspace object reference */
    } ExportParams;

    typedef structure {
        string  shock_id;     /* shock id of file to export */
     } ExportOutput;

    /** Wrapper function for use by in-narrative downloaders to download expressions from shock **/

    funcdef export_expression(ExportParams params)
                     returns (ExportOutput output)
                     authentication required;

    /*
        Get Expression Matrix from Expression Set input
    */

    /**
        Following are the required input parameters to get Expression Matrix
    **/

    typedef structure {

        string      workspace_name;
        string      output_obj_name;
        string      expressionset_ref;

    } getExprMatrixParams;

    typedef structure {

        string   exprMatrix_FPKM_ref;
        string   exprMatrix_TPM_ref;

    } getExprMatrixOutput;

    funcdef  get_expressionMatrix(getExprMatrixParams params)
                                   returns (getExprMatrixOutput)
                                   authentication required;
};
