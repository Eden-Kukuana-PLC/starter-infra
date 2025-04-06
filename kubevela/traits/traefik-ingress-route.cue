"traefik-ingress-route": {
//	alias: ""
	annotations: {}
	attributes: {
		appliesToWorkloads: []
		conflictsWith: []
		podDisruptive:   false
		workloadRefPath: ""
	}
	description: "Traefik ingress and secure ingress route trait"
	labels: {}
	type: "trait"
	spec: {
		name: "traefik-ingress-route"
	}
}

template: {
	patch: {}
	parameter: {
		name: string
		routes: [...{
			kind: *"Rule" | string
			match: string
			services: [...{
				name: string
				port: int
			}]
		}]
	}
	outputs: secureingress: {
		apiVersion: "traefik.io/v1alpha1"
		kind: 			"IngressRoute"
		metadata: {
			name: "secure-\(parameter.name)"
			namespace: context.namespace
		}
		spec: {
			name: "secure-\(parameter.name)"
			extryPoints: ["websecure"]
			tls: {
				certResolver: "letsEncrypt"
			}
			routes: [
				for route in parameter.routes {
					kind: route.kind
					match: route.match
					services: [
						for service in route.services {
							name: service.name
							port: service.port
						}
					]
				}
			]
		}
	}
	outputs: ingress: {
		apiVersion: "traefik.io/v1alpha1"
		kind: 			"IngressRoute"
		metadata: {
			name: parameter.name
			namespace: context.namespace
		}
		spec: {
			name: parameter.name
			entryPoints: "web"
			routes: [
				for route in parameter.routes {
					kind: route.kind
					match: route.match
					services: [
						for service in route.services {
							name: service.name
							port: service.port
						}
					]
				}
			]
		}
	}
}

