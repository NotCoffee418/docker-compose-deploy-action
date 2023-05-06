# docker-compose-deploy-action
Action to deploy a docker-compose file from from GitHub.

### Example
```yaml
name: Deploy

on:
  push:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-20.04

    steps:
      - uses: actions/checkout@v2

      # ... your other steps ...

      - name: Deploy
        uses: NotCoffee418/docker-compose-deploy-action@v1
        with:
          host: ${{ secrets.HOST_IP }}
          user: caleb
          key: ${{ secrets.CALEB_GITHUB_PRIVKEY }}
          repository: git@github.com:CalebTradingBot/Caleb.git
          deployer_path: /data/caleb/deployer
          docker_compose_file: docker-compose-prod.yml

```
