# -*- coding: utf-8 -*-
#BEGIN_HEADER
import os
import sys
import time
import shutil
import glob
import logging
from datetime import datetime

from pprint import pprint
from pprint import pformat

from DataFileUtil.DataFileUtilClient import DataFileUtil
from DataFileUtil.baseclient import ServerError as DFUError
from Workspace.WorkspaceClient import Workspace
from Workspace.baseclient import ServerError as WorkspaceError
from ReadsAlignmentUtils.ReadsAlignmentUtilsClient import ReadsAlignmentUtils
from core.expression_utils import ExpressionUtils as Expression_Utils
from core.gff_utils import GFFUtils
from core.table_maker import TableMaker

#END_HEADER


class ExpressionUtils:
    '''
    Module Name:
    ExpressionUtils

    Module Description:
    A KBase module: ExpressionUtils

This module is intended for use by Assemblers to upload RNASeq Expression files
(gtf, fpkm and ctab). This module generates the ctab files and tpm data if they are absent.
The expression files are uploaded as a single compressed file.This module also generates
expression levels and tpm expression levels from the input files and saves them in the
workspace object. Once uploaded, the expression files can be downloaded onto an output directory.
    '''

    ######## WARNING FOR GEVENT USERS ####### noqa
    # Since asynchronous IO can lead to methods - even the same method -
    # interrupting each other, you must be *very* careful when using global
    # state. A method could easily clobber the state set by another while
    # the latter method is running.
    ######################################### noqa
    VERSION = "0.0.1"
    GIT_URL = "git@github.com:arfathpasha/ExpressionUtils.git"
    GIT_COMMIT_HASH = "a4592effdd4a8dd187e4673ca453535a1da3a1c3"

    #BEGIN_CLASS_HEADER

    PARAM_IN_SRC_DIR = 'source_dir'
    PARAM_IN_SRC_REF = 'source_ref'
    PARAM_IN_DST_REF = 'destination_ref'
    PARAM_IN_ALIGNMENT_REF = 'alignment_ref'
    PARAM_IN_TOOL_USED = 'tool_used'
    PARAM_IN_TOOL_VER = 'tool_version'

    PARAM_IN_ANNOTATION_REF = 'annotation_ref'
    PARAM_IN_BAM_FILE_PATH = 'bam_file_path'
    PARAM_IN_TOOL_OPTS = 'tool_opts'
    PARAM_IN_DESCRIPTION = 'description'
    PARAM_IN_DATA_QUAL_LEVEL = 'data_quality_level'
    PARAM_IN_PROC_COMMENTS = 'processing_comments'
    PARAM_IN_PLATFORM = 'platform'
    PARAM_IN_MAPPED_SAMPLE_ID = 'mapped_sample_id'
    PARAM_IN_ORIG_MEDIAN = 'original_median'
    PARAM_IN_EXT_SRC_DATE = 'external_source_date'
    PARAM_IN_SRC = 'source'

    PARAM_IN_READ_LIB_REF = 'read_lib_ref'

    def _check_required_param(self, in_params, param_list):
        """
        Check if each of the params in the list are in the input params
        """
        for param in param_list:
            if (param not in in_params or not in_params[param]):
                raise ValueError('{} parameter is required'.format(param))

    def _proc_ws_obj_params(self, ctx, params):
        """
        Check the validity of workspace and object params and return them
        """
        dst_ref = params.get(self.PARAM_IN_DST_REF)

        ws_name_id, obj_name_id = os.path.split(dst_ref)

        if not bool(ws_name_id.strip()) or ws_name_id == '/':
            raise ValueError("Workspace name or id is required in " + self.PARAM_IN_DST_REF)

        if not bool(obj_name_id.strip()):
            raise ValueError("Object name or id is required in " + self.PARAM_IN_DST_REF)

        dfu = DataFileUtil(self.callback_url)

        if not isinstance(ws_name_id, int):

            try:
                ws_name_id = dfu.ws_name_to_id(ws_name_id)
            except DFUError as se:
                prefix = se.message.split('.')[0]
                raise ValueError(prefix)

        self.__LOGGER.info('Obtained workspace name/id ' + str(ws_name_id))

        return ws_name_id, obj_name_id

    def _proc_upload_expression_params(self, ctx, params):
        """
        Check the presence and validity of upload expression params
        """
        self._check_required_param(params, [self.PARAM_IN_DST_REF,
                                            self.PARAM_IN_SRC_DIR,
                                            self.PARAM_IN_ALIGNMENT_REF,
                                            self.PARAM_IN_TOOL_USED,
                                            self.PARAM_IN_TOOL_VER,
                                            ])

        ws_name_id, obj_name_id = self._proc_ws_obj_params(ctx, params)

        source_dir = params.get(self.PARAM_IN_SRC_DIR)

        if not (os.path.isdir(source_dir)):
            raise ValueError('Source directory does not exist: ' + source_dir)

        if not os.listdir(source_dir):
            raise ValueError('Source directory is empty: ' + source_dir)

        return ws_name_id, obj_name_id, source_dir

    def _get_ws_info(self, obj_ref):

        ws = Workspace(self.ws_url)
        try:
            info = ws.get_object_info_new({'objects': [{'ref': obj_ref}]})[0]
        except WorkspaceError as wse:
            self.__LOGGER.error('Logging workspace exception')
            self.__LOGGER.error(str(wse))
            raise
        return info

    def _get_annotation(self, params, genome_or_assembly_ref, workspace):

        if self.PARAM_IN_ANNOTATION_REF in params and \
           params[self.PARAM_IN_ANNOTATION_REF] is not None:
            return params[self.PARAM_IN_ANNOTATION_REF]

        obj_type = self._get_ws_info(genome_or_assembly_ref)[2]
        if obj_type.startswith('KBaseGenomes.Genome'):
            annotation_ref = self.gff_utils.create_gtf_annotation_from_genome(genome_or_assembly_ref, workspace)
        elif obj_type.startswith('KBaseGenomeAnnotations.Assembly') or \
                obj_type.startswith('KBaseGenomes.ContigSet'):
            raise ValueError((self.PARAM_IN_ANNOTATION_REF + ' parameter is required'))
        else:
            raise ValueError('Parameter type should be assembly or genome ref and not ' + obj_type)
        return annotation_ref

    def _get_expression_levels(self, source_dir):

        fpkm_file = os.path.join(source_dir, 'genes.fpkm_tracking')

        if not os.path.isfile(fpkm_file):
            raise ValueError('{0} file is required in {1}'.format(fpkm_file, source_dir))

        return self.expression_utils.get_expression_levels(os.path.join(source_dir, fpkm_file))

    def _gen_ctab_files(self, params, alignment_ref):

        source_dir = params.get(self.PARAM_IN_SRC_DIR)
        if len(glob.glob(source_dir + '/*.ctab')) < 5:

            print(' =======  Generating ctab files ==========')
            gtf_file = os.path.join(source_dir, 'transcripts.gtf')
            if not os.path.isfile(gtf_file):
                raise ValueError("{} file is required to generate ctab files, found missing".
                                 format(gtf_file))

            if self.PARAM_IN_BAM_FILE_PATH in params and \
               params[self.PARAM_IN_BAM_FILE_PATH] is not None:
                bam_file_path = params[self.PARAM_IN_BAM_FILE_PATH]
            else:
                print('Downloading bam file from alignment object')
                rau = ReadsAlignmentUtils(self.callback_url)
                alignment_retVal = rau.download_alignment({'source_ref': alignment_ref})
                alignment_dir = alignment_retVal.get('destination_dir')
                tmp_file_path = os.path.join(alignment_dir, 'accepted_hits.bam')
                if os.path.isfile(tmp_file_path):
                    bam_file_path = tmp_file_path
                else:
                    tmp_file_path = os.path.join(alignment_dir, 'accepted_hits_sorted.bam')
                    if os.path.isfile(tmp_file_path):
                        bam_file_path = tmp_file_path
                    else:
                        raise ValueError('accepted_hits.bam or accepted_hits_sorted.bam not found in {}'.
                                         format(alignment_dir))
            result = self.table_maker.build_ctab_files(
                ref_genome_path=gtf_file,
                alignment_path=bam_file_path,
                output_dir=source_dir)
            if result != 0:
                raise ValueError('Tablemaker failed')

    #END_CLASS_HEADER

    # config contains contents of config file in a hash or None if it couldn't
    # be found
    def __init__(self, config):
        #BEGIN_CONSTRUCTOR
        self.__LOGGER = logging.getLogger('ExpressionUtils')
        self.__LOGGER.setLevel(logging.INFO)
        streamHandler = logging.StreamHandler(sys.stdout)
        formatter = logging.Formatter(
            "%(asctime)s - %(filename)s - %(lineno)d - %(levelname)s - %(message)s")
        formatter.converter = time.gmtime
        streamHandler.setFormatter(formatter)
        self.__LOGGER.addHandler(streamHandler)
        self.__LOGGER.info("Logger was set")

        self.config = config
        self.scratch = config['scratch']
        self.callback_url = os.environ['SDK_CALLBACK_URL']
        self.ws_url = config['workspace-url']
        self.expression_utils = Expression_Utils(config)
        self.dfu = DataFileUtil(self.callback_url)
        self.gff_utils = GFFUtils(config, self.__LOGGER)
        self.table_maker = TableMaker(config, self.__LOGGER)
        #END_CONSTRUCTOR
        pass


    def upload_expression(self, ctx, params):
        """
        Uploads the expression  *
        :param params: instance of type "UploadExpressionParams" (*   
           Required input parameters for uploading a reads expression data
           string   destination_ref        -   object reference of expression
           data. The object ref is 'ws_name_or_id/obj_name_or_id' where
           ws_name_or_id is the workspace name or id and obj_name_or_id is
           the object name or id string   source_dir             -  
           directory with the files to be uploaded string   alignment_ref    
           -   alignment workspace object reference string   tool_used       
           -   stringtie or cufflinks string   tool_version           -  
           version of the tool used *) -> structure: parameter
           "destination_ref" of String, parameter "source_dir" of String,
           parameter "alignment_ref" of String, parameter "tool_used" of
           String, parameter "tool_version" of String, parameter
           "annotation_ref" of String, parameter "bam_file_path" of String,
           parameter "data_quality_level" of Long, parameter
           "original_median" of Double, parameter "description" of String,
           parameter "platform" of String, parameter "source" of String,
           parameter "external_source_date" of String, parameter
           "processing_comments" of String, parameter "tool_opts" of mapping
           from String to String
        :returns: instance of type "UploadExpressionOutput" (*     Output
           from upload expression    *) -> structure: parameter "obj_ref" of
           String
        """
        # ctx is the context object
        # return variables are: returnVal
        #BEGIN upload_expression

        self.__LOGGER.info('Starting upload expression, parsing parameters ')
        pprint(params)

        ws_name_id, obj_name_id, source_dir = self._proc_upload_expression_params(ctx, params)

        alignment_ref = params.get(self.PARAM_IN_ALIGNMENT_REF)
        try:
            alignment_obj = self.dfu.get_objects({'object_refs': [alignment_ref]})['data'][0]
        except DFUError as e:
            self.__LOGGER.error('Logging stacktrace from workspace exception:\n' + e.data)
            raise

        alignment = alignment_obj['data']
        assembly_or_genome_ref = alignment['genome_id']
        annotation_ref = self._get_annotation(params, assembly_or_genome_ref, ws_name_id)

        expression_levels, tpm_expression_levels = self._get_expression_levels(source_dir)

        self._gen_ctab_files(params, alignment_ref)

        uploaded_file = self.dfu.file_to_shock({'file_path': source_dir,
                                                'make_handle': 1,
                                                'pack': 'zip'
                                                })
        """
        move the zipfile created in the source directory one level up
        """
        path, dir = os.path.split(source_dir)
        zipfile = dir + '.zip'
        if os.path.isfile(os.path.join(source_dir, zipfile)):
            shutil.move(os.path.join(source_dir, zipfile), os.path.join(path, zipfile))

        file_handle = uploaded_file['handle']
        file_size = uploaded_file['size']

        expression_data = {'id': obj_name_id,
                           'type': 'RNA-KBaseRNASeq.RNASeqExpression',
                           'numerical_interpretation': 'FPKM',
                           'genome_id': assembly_or_genome_ref,
                           'annotation_id': annotation_ref,
                           'mapped_rnaseq_alignment': {alignment['read_sample_id']: alignment_ref},
                           'condition': alignment['condition'],
                           'file': file_handle,
                           'expression_levels': expression_levels,
                           'tpm_expression_levels': tpm_expression_levels
                           }
        additional_params = [self.PARAM_IN_TOOL_USED,
                             self.PARAM_IN_TOOL_VER,
                             self.PARAM_IN_TOOL_OPTS,
                             self.PARAM_IN_DESCRIPTION,
                             self.PARAM_IN_DATA_QUAL_LEVEL,
                             self.PARAM_IN_PLATFORM,
                             self.PARAM_IN_PROC_COMMENTS,
                             self.PARAM_IN_MAPPED_SAMPLE_ID,
                             self.PARAM_IN_ORIG_MEDIAN,
                             self.PARAM_IN_EXT_SRC_DATE,
                             self.PARAM_IN_SRC
                             ]

        for opt_param in additional_params:
            if opt_param in params and params[opt_param] is not None:
                expression_data[opt_param] = params[opt_param]

        res = self.dfu.save_objects(
            {"id": ws_name_id,
             "objects": [{
                          "type": "KBaseRNASeq.RNASeqExpression",
                          "data": expression_data,
                          "name": obj_name_id}
                         ]})[0]

        self.__LOGGER.info('save complete')

        returnVal = {'obj_ref': str(res[6]) + '/' + str(res[0]) + '/' + str(res[4])}

        print('Uploaded object: ')
        print(returnVal)
        #END upload_expression

        # At some point might do deeper type checking...
        if not isinstance(returnVal, dict):
            raise ValueError('Method upload_expression return value ' +
                             'returnVal is not type dict as required.')
        # return the results
        return [returnVal]

    def download_expression(self, ctx, params):
        """
        Downloads expression *
        :param params: instance of type "DownloadExpressionParams" (*
           Required input parameters for downloading expression string
           source_ref         -       object reference of expression source.
           The object ref is 'ws_name_or_id/obj_name_or_id' where
           ws_name_or_id is the workspace name or id and obj_name_or_id is
           the object name or id *) -> structure: parameter "source_ref" of
           String
        :returns: instance of type "DownloadExpressionOutput" (*  The output
           of the download method.  *) -> structure: parameter
           "destination_dir" of String
        """
        # ctx is the context object
        # return variables are: returnVal
        #BEGIN download_expression

        self.__LOGGER.info('Running download_expression with params:\n' +
                 pformat(params))

        inref = params.get(self.PARAM_IN_SRC_REF)
        if not inref:
            raise ValueError(self.PARAM_IN_SRC_REF + ' parameter is required')

        try:
            expression = self.dfu.get_objects({'object_refs': [inref]})['data']
        except DFUError as e:
            self.__LOGGER.error('Logging stacktrace from workspace exception:\n' + e.data)
            raise

        # set the output dir
        timestamp = int((datetime.utcnow() - datetime.utcfromtimestamp(0)).total_seconds() * 1000)
        output_dir = os.path.join(self.scratch, 'download_' + str(timestamp))
        os.mkdir(output_dir)

        file_ret = self.dfu.shock_to_file({
                                           'shock_id': expression[0]['data']['file']['id'],
                                           'file_path': output_dir,
                                           'unpack': 'unpack'
                                           })

        if not os.listdir(output_dir):
            raise ValueError('No files were downloaded: ' + output_dir)

        for f in glob.glob(output_dir + '/*.zip'):
            os.remove(f)

        returnVal = {'destination_dir': output_dir}

        #END download_expression

        # At some point might do deeper type checking...
        if not isinstance(returnVal, dict):
            raise ValueError('Method download_expression return value ' +
                             'returnVal is not type dict as required.')
        # return the results
        return [returnVal]

    def export_expression(self, ctx, params):
        """
        Wrapper function for use by in-narrative downloaders to download expressions from shock *
        :param params: instance of type "ExportParams" (* Required input
           parameters for exporting expression string   source_ref         - 
           object reference of expression source. The object ref is
           'ws_name_or_id/obj_name_or_id' where ws_name_or_id is the
           workspace name or id and obj_name_or_id is the object name or id
           *) -> structure: parameter "source_ref" of String
        :returns: instance of type "ExportOutput" -> structure: parameter
           "shock_id" of String
        """
        # ctx is the context object
        # return variables are: output
        #BEGIN export_expression

        inref = params.get(self.PARAM_IN_SRC_REF)
        if not inref:
            raise ValueError(self.PARAM_IN_SRC_REF + ' parameter is required')

        try:
            expression = self.dfu.get_objects({'object_refs': [inref]})['data']
        except DFUError as e:
            self.__LOGGER.error('Logging stacktrace from workspace exception:\n' + e.data)
            raise

        output = {'shock_id': expression[0]['data']['file']['id']}

        #END export_expression

        # At some point might do deeper type checking...
        if not isinstance(output, dict):
            raise ValueError('Method export_expression return value ' +
                             'output is not type dict as required.')
        # return the results
        return [output]
    def status(self, ctx):
        #BEGIN_STATUS
        returnVal = {'state': "OK",
                     'message': "",
                     'version': self.VERSION,
                     'git_url': self.GIT_URL,
                     'git_commit_hash': self.GIT_COMMIT_HASH}
        #END_STATUS
        return [returnVal]
