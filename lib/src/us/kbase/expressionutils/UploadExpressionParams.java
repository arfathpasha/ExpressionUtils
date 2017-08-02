
package us.kbase.expressionutils;

import java.util.HashMap;
import java.util.Map;
import javax.annotation.Generated;
import com.fasterxml.jackson.annotation.JsonAnyGetter;
import com.fasterxml.jackson.annotation.JsonAnySetter;
import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.annotation.JsonProperty;
import com.fasterxml.jackson.annotation.JsonPropertyOrder;


/**
 * <p>Original spec-file type: UploadExpressionParams</p>
 * <pre>
 * *    Required input parameters for uploading a reads expression data
 *         string   destination_ref        -   object reference of expression data.
 *                                             The object ref is 'ws_name_or_id/obj_name_or_id'
 *                                             where ws_name_or_id is the workspace name or id
 *                                             and obj_name_or_id is the object name or id
 *                                             
 *         string   source_dir             -   directory with the files to be uploaded
 *         string   alignment_ref          -   alignment workspace object reference
 *     *
 * </pre>
 * 
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
@Generated("com.googlecode.jsonschema2pojo")
@JsonPropertyOrder({
    "destination_ref",
    "source_dir",
    "alignment_ref",
    "genome_ref",
    "annotation_id",
    "bam_file_path",
    "data_quality_level",
    "original_median",
    "description",
    "platform",
    "source",
    "external_source_date",
    "processing_comments"
})
public class UploadExpressionParams {

    @JsonProperty("destination_ref")
    private String destinationRef;
    @JsonProperty("source_dir")
    private String sourceDir;
    @JsonProperty("alignment_ref")
    private String alignmentRef;
    @JsonProperty("genome_ref")
    private String genomeRef;
    @JsonProperty("annotation_id")
    private String annotationId;
    @JsonProperty("bam_file_path")
    private String bamFilePath;
    @JsonProperty("data_quality_level")
    private Long dataQualityLevel;
    @JsonProperty("original_median")
    private Double originalMedian;
    @JsonProperty("description")
    private String description;
    @JsonProperty("platform")
    private String platform;
    @JsonProperty("source")
    private String source;
    @JsonProperty("external_source_date")
    private String externalSourceDate;
    @JsonProperty("processing_comments")
    private String processingComments;
    private Map<String, Object> additionalProperties = new HashMap<String, Object>();

    @JsonProperty("destination_ref")
    public String getDestinationRef() {
        return destinationRef;
    }

    @JsonProperty("destination_ref")
    public void setDestinationRef(String destinationRef) {
        this.destinationRef = destinationRef;
    }

    public UploadExpressionParams withDestinationRef(String destinationRef) {
        this.destinationRef = destinationRef;
        return this;
    }

    @JsonProperty("source_dir")
    public String getSourceDir() {
        return sourceDir;
    }

    @JsonProperty("source_dir")
    public void setSourceDir(String sourceDir) {
        this.sourceDir = sourceDir;
    }

    public UploadExpressionParams withSourceDir(String sourceDir) {
        this.sourceDir = sourceDir;
        return this;
    }

    @JsonProperty("alignment_ref")
    public String getAlignmentRef() {
        return alignmentRef;
    }

    @JsonProperty("alignment_ref")
    public void setAlignmentRef(String alignmentRef) {
        this.alignmentRef = alignmentRef;
    }

    public UploadExpressionParams withAlignmentRef(String alignmentRef) {
        this.alignmentRef = alignmentRef;
        return this;
    }

    @JsonProperty("genome_ref")
    public String getGenomeRef() {
        return genomeRef;
    }

    @JsonProperty("genome_ref")
    public void setGenomeRef(String genomeRef) {
        this.genomeRef = genomeRef;
    }

    public UploadExpressionParams withGenomeRef(String genomeRef) {
        this.genomeRef = genomeRef;
        return this;
    }

    @JsonProperty("annotation_id")
    public String getAnnotationId() {
        return annotationId;
    }

    @JsonProperty("annotation_id")
    public void setAnnotationId(String annotationId) {
        this.annotationId = annotationId;
    }

    public UploadExpressionParams withAnnotationId(String annotationId) {
        this.annotationId = annotationId;
        return this;
    }

    @JsonProperty("bam_file_path")
    public String getBamFilePath() {
        return bamFilePath;
    }

    @JsonProperty("bam_file_path")
    public void setBamFilePath(String bamFilePath) {
        this.bamFilePath = bamFilePath;
    }

    public UploadExpressionParams withBamFilePath(String bamFilePath) {
        this.bamFilePath = bamFilePath;
        return this;
    }

    @JsonProperty("data_quality_level")
    public Long getDataQualityLevel() {
        return dataQualityLevel;
    }

    @JsonProperty("data_quality_level")
    public void setDataQualityLevel(Long dataQualityLevel) {
        this.dataQualityLevel = dataQualityLevel;
    }

    public UploadExpressionParams withDataQualityLevel(Long dataQualityLevel) {
        this.dataQualityLevel = dataQualityLevel;
        return this;
    }

    @JsonProperty("original_median")
    public Double getOriginalMedian() {
        return originalMedian;
    }

    @JsonProperty("original_median")
    public void setOriginalMedian(Double originalMedian) {
        this.originalMedian = originalMedian;
    }

    public UploadExpressionParams withOriginalMedian(Double originalMedian) {
        this.originalMedian = originalMedian;
        return this;
    }

    @JsonProperty("description")
    public String getDescription() {
        return description;
    }

    @JsonProperty("description")
    public void setDescription(String description) {
        this.description = description;
    }

    public UploadExpressionParams withDescription(String description) {
        this.description = description;
        return this;
    }

    @JsonProperty("platform")
    public String getPlatform() {
        return platform;
    }

    @JsonProperty("platform")
    public void setPlatform(String platform) {
        this.platform = platform;
    }

    public UploadExpressionParams withPlatform(String platform) {
        this.platform = platform;
        return this;
    }

    @JsonProperty("source")
    public String getSource() {
        return source;
    }

    @JsonProperty("source")
    public void setSource(String source) {
        this.source = source;
    }

    public UploadExpressionParams withSource(String source) {
        this.source = source;
        return this;
    }

    @JsonProperty("external_source_date")
    public String getExternalSourceDate() {
        return externalSourceDate;
    }

    @JsonProperty("external_source_date")
    public void setExternalSourceDate(String externalSourceDate) {
        this.externalSourceDate = externalSourceDate;
    }

    public UploadExpressionParams withExternalSourceDate(String externalSourceDate) {
        this.externalSourceDate = externalSourceDate;
        return this;
    }

    @JsonProperty("processing_comments")
    public String getProcessingComments() {
        return processingComments;
    }

    @JsonProperty("processing_comments")
    public void setProcessingComments(String processingComments) {
        this.processingComments = processingComments;
    }

    public UploadExpressionParams withProcessingComments(String processingComments) {
        this.processingComments = processingComments;
        return this;
    }

    @JsonAnyGetter
    public Map<String, Object> getAdditionalProperties() {
        return this.additionalProperties;
    }

    @JsonAnySetter
    public void setAdditionalProperties(String name, Object value) {
        this.additionalProperties.put(name, value);
    }

    @Override
    public String toString() {
        return ((((((((((((((((((((((((((((("UploadExpressionParams"+" [destinationRef=")+ destinationRef)+", sourceDir=")+ sourceDir)+", alignmentRef=")+ alignmentRef)+", genomeRef=")+ genomeRef)+", annotationId=")+ annotationId)+", bamFilePath=")+ bamFilePath)+", dataQualityLevel=")+ dataQualityLevel)+", originalMedian=")+ originalMedian)+", description=")+ description)+", platform=")+ platform)+", source=")+ source)+", externalSourceDate=")+ externalSourceDate)+", processingComments=")+ processingComments)+", additionalProperties=")+ additionalProperties)+"]");
    }

}
