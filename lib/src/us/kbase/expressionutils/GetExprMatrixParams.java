
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
 * <p>Original spec-file type: getExprMatrixParams</p>
 * <pre>
 * *
 * Following are the required input parameters to get Expression Matrix
 *     *
 * </pre>
 * 
 */
@JsonInclude(JsonInclude.Include.NON_NULL)
@Generated("com.googlecode.jsonschema2pojo")
@JsonPropertyOrder({
    "workspace_name",
    "output_obj_name",
    "expressionset_ref"
})
public class GetExprMatrixParams {

    @JsonProperty("workspace_name")
    private String workspaceName;
    @JsonProperty("output_obj_name")
    private String outputObjName;
    @JsonProperty("expressionset_ref")
    private String expressionsetRef;
    private Map<String, Object> additionalProperties = new HashMap<String, Object>();

    @JsonProperty("workspace_name")
    public String getWorkspaceName() {
        return workspaceName;
    }

    @JsonProperty("workspace_name")
    public void setWorkspaceName(String workspaceName) {
        this.workspaceName = workspaceName;
    }

    public GetExprMatrixParams withWorkspaceName(String workspaceName) {
        this.workspaceName = workspaceName;
        return this;
    }

    @JsonProperty("output_obj_name")
    public String getOutputObjName() {
        return outputObjName;
    }

    @JsonProperty("output_obj_name")
    public void setOutputObjName(String outputObjName) {
        this.outputObjName = outputObjName;
    }

    public GetExprMatrixParams withOutputObjName(String outputObjName) {
        this.outputObjName = outputObjName;
        return this;
    }

    @JsonProperty("expressionset_ref")
    public String getExpressionsetRef() {
        return expressionsetRef;
    }

    @JsonProperty("expressionset_ref")
    public void setExpressionsetRef(String expressionsetRef) {
        this.expressionsetRef = expressionsetRef;
    }

    public GetExprMatrixParams withExpressionsetRef(String expressionsetRef) {
        this.expressionsetRef = expressionsetRef;
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
        return ((((((((("GetExprMatrixParams"+" [workspaceName=")+ workspaceName)+", outputObjName=")+ outputObjName)+", expressionsetRef=")+ expressionsetRef)+", additionalProperties=")+ additionalProperties)+"]");
    }

}
