
# Docker Compose Deploy Action

This GitHub Action deploys a repository using Docker Compose on a remote server through SSH.

## Usage

To use this action, add the following YAML code to your GitHub Actions workflow:

```yaml
name: Deploy My App
on:
  push:
    branches:
      - main
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - name: Deploy
      uses: notcoffee418/docker-compose-deploy-action@v4
      with:
        ssh_host: ${{ secrets.SSH_HOST }}
        ssh_user: ${{ secrets.SSH_USERNAME }}
        ssh_key: ${{ secrets.SSH_PRIVATE_KEY }}
        ssh_deployer_path: /path/to/deployer/directory
        repository: yourusername/yourrepository
        docker_compose_file: docker-compose.yml
```

Replace `/path/to/deployer/directory` with your own values. Also, make sure to have a valid `SSH_HOST`, `SSH_USERNAME` and `SSH_PRIVATE_KEY` secret in your repository's secrets.

Got it. Here’s an updated version with clear instructions on giving your server access to your GitHub repositories, and placing the SSH key in a specific directory:


## Accessing Private Repositories

To give your server access to your GitHub repositories using SSH keys, follow these steps:

1. **Generate SSH Key Pair on Deployment Server:**
   ```bash
   su YOUR_DEPLOYER_USER
   mkdir -p ~/.ssh/github-keys
   ssh-keygen -t rsa -b 4096 -C "your_github_email@github.com" -f ~/.ssh/github-keys/id_rsa
   chmod 400 ~/.ssh/github-keys/id_rsa
   ```
   You can find the email address in your [GitHub Settings](https://github.com/settings/emails).

2. **Add Public Key to GitHub:**
   - Copy the public key:
     ```bash
     cat ~/.ssh/github-keys/id_rsa.pub
     ```
   - Go to your repository on GitHub > Settings > Deploy keys.
   - Click "Add deploy key" and paste your public key as authentication key.

3. **Configure Git to Use the SSH Key:**
   - Edit your SSH configuration file (`~/.ssh/config`) to use the new key for GitHub:
    ```bash
    mkdir -p ~/.ssh
    echo -e "Host github.com\n  IdentityFile ~/.ssh/github-keys/id_rsa\n  User git" >> ~/.ssh/config
    ```
   - Test the connection and approve fingerprint on first time connecting:
    ```bash
    ssh -T git@github.com
    ```


## Contributing

If you have suggestions for how this GitHub Action could be improved, or want to report a bug, please open an issue or a pull request in this repository.

## License

This GitHub Action is licensed under the [MIT License](LICENSE).
