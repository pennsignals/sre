job "grafana" {
  datacenters = ["dc1"]
  type = "service"

  group "grafana" {
    count = 1

    network {
      port "http"  { static = 3000 }
    }

    task "grafana" {
      driver = "docker"

      config {
        image = "grafana/grafana-oss:9.4.7"
        ports = [ "http" ]
        volumes = ["/deploy/grafana-data/var/lib/grafana:/var/lib/grafana",
          "/deploy/grafana-data/etc/grafana:/etc/grafana"]
      }

      service {
        name = "grafana"
        port = "http"
        tags = ["ui"]
        check {
          name = "grafana UI TCP Check"
          type = "tcp"
          interval = "10s"
          timeout = "2s"
        }
      }
    }
  }
}
