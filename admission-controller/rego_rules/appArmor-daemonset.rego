# PolicyName: PSS - Baseline - DaemonSet with containers that use unauthorized AppArmor profiles
# Description: This policy identifies DaemonSets with containers that use unauthorized AppArmor profiles

allowed_profile_types = {"runtime", "localhost"}
match[{"msg": msg}] {
    input.request.operation == "CREATE"
    input.request.kind.kind == "DaemonSet"
    container := input.request.object.spec.template.spec
    containerNames := container.containers
    profileName := {name | name := input.request.object.spec.template.metadata.annotations[sprintf("container.apparmor.security.beta.kubernetes.io/%v",[containerNames[_].name])]}
    names := profileName[_]
    profiles := {i | i := split(names, "/")[0]}
    disallowedProfiles := profiles - allowed_profile_types
    count(disallowedProfiles) != 0
    name := input.request.object.metadata.name
    msg := sprintf("DaemonSet with containers using unauthorized AppArmor profiles identified in: %v", [name])
}