locals {
    common_tags = {
        project = "azure-landing-zone-demo"
        owner = "devsocket"
        env = var.environment
        costcenter = "demo"
        managedBy = "terraform"
        compliance = "baseline"
    }
}