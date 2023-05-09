
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
      uses: NotCoffee418/docker-compose-deploy-action@v3
      with:
        ssh_host: ${{ secrets.SSH_HOST }}
        ssh_user: ${{ secrets.SSH_USERNAME }}
        ssh_key: ${{ secrets.SSH_PRIVATE_KEY }}
        ssh_deployer_path: /path/to/deployer/directory
        repository: yourusername/yourrepository
        docker_compose_file: docker-compose.yml
```

Replace `/path/to/deployer/directory` with your own values. Also, make sure to have a valid `SSH_HOST`, `SSH_USERNAME` and `SSH_PRIVATE_KEY` secret in your repository's secrets.

## Accessing Private Repositories

If you need to deploy a private repository, you can use SSH keys for authentication. Here's how:

1. Generate an SSH key pair on your local machine if you haven't already done so. You can do this by running the command `ssh-keygen` in your terminal.

2. Add the public key to your GitHub account. Go to your GitHub account settings, then click on "SSH and GPG keys" in the left menu. Click the "New SSH key" button, then copy and paste your public key into the "Key" field.

3. Add the private key to your deployment environment. In your deployment environment, create a file called `id_rsa` in the `~/.ssh` directory (or use a different filename if you prefer). Copy the contents of the private key you generated in step 1 into this file.

4. Set the appropriate permissions on the private key file. Run the command `chmod 400 ~/.ssh/id_rsa`.

5. Configure Git to use the SSH key for authentication. Run the command `git config --global core.sshCommand "ssh -i ~/.ssh/id_rsa"`. This tells Git to use your private key for SSH authentication.

After completing these steps, you should be able to deploy private repositories via SSH without needing to log in first. The SSH key will be used for authentication instead.

## Contributing

If you have suggestions for how this GitHub Action could be improved, or want to report a bug, please open an issue or a pull request in this repository. 

## License

This GitHub Action is licensed under the [MIT License](LICENSE).
