"env-from": {
    type: "trait"
    annotations: {}
    labels: {
        "ui-hidden": "true"
    }
    description: "Consumes the content of the ConfigMap as environment variables on K8s pod for your workload which follows the pod spec in path 'spec.template'"
    attributes: appliesToWorkloads: ["*"]
}
template: {
    patch: {
            spec: template: spec: {
                    // +patchKey=name
                    containers: [{
                            name: context.name
                             envFrom: [
																if parameter.secretRef != _|_ && parameter.secretRef != "" {
																		{
																				secretRef: {
																						name: parameter.secretRef
																				}
																		}
																}
														]
                    }]
            }
    }

    parameter: {
            secretRef?: string
    }
}