from pulumi_docker_build import Image, BuildContextArgs, RegistryArgs

Image(
    "api-image",
    context=BuildContextArgs(location="../apps/api"),
    tags=["api:latest"],
    # registries=[RegistryArgs(address="10.0.0.42:32000")],
    push=False,
)
