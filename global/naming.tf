locals {
    org = "devsocket"
    env = var.environment
    region = var.region
    project = "l3-landingzone"

    names = {
        rg_core = "${local.org}-${local.project}-${local.env}-rg"
        log-wa = "${local.org}-${local.env}-law"
        sa_state = "${local.org}${local.env}tfstate"
        kv = "${local.org}-${local.env}-kv"
        acr = "${local.org}-${local.env}acr"
    }
    
}