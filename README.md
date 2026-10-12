
# Docker Compose Deploy Action

This GitHub Action deploys a repository using Docker Compose on a remote server through SSH.

> [!WARNING]
> **This action runs commands on your server over SSH, and the deploy user can run Docker (effectively root).**
> Anyone who can change the workflow, the deployed branch, or the deployed repo's compose file can run code on that server and read the SSH secrets.
> - Trigger it only from `push` or `workflow_dispatch` on a protected branch. Never from pull requests or `pull_request_target`.
> - Pin the action to a commit SHA and set `ssh_known_hosts` (see [Security notes](#security-notes)).
> - Use a dedicated deploy user and key. Don't reuse your personal account or key.
> - Try it on a non-critical server first. It stops (`docker compose down`) and rebuilds your stack on every run.

## Usage

To use this action, add the following YAML code to your GitHub Actions workflow:

```yaml
name: Deploy My App
on:
  push:
    branches:
      - main
permissions: {}   # this action does not need any GITHUB_TOKEN permissions
concurrency: deploy   # never run two deployments at once
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
    - name: Deploy
      uses: notcoffee418/docker-compose-deploy-action@v5
      with:
        ssh_host: ${{ secrets.SSH_HOST }}
        ssh_user: ${{ secrets.SSH_USERNAME }}
        ssh_key: ${{ secrets.SSH_PRIVATE_KEY }}
        ssh_port: ${{ secrets.SSH_PORT }}
        ssh_known_hosts: ${{ secrets.SSH_KNOWN_HOSTS }}
        ssh_deployer_path: /path/to/deployer/directory
        repository: yourusername/yourrepository
        docker_compose_file: docker-compose.yml
```

Replace `/path/to/deployer/directory` with your own values. Also, make sure to have a valid `SSH_HOST`, `SSH_USERNAME` and `SSH_PRIVATE_KEY` secret in your repository's secrets.

## Security notes

- **Do not run this on pull requests.** Trigger it from `push` (or `workflow_dispatch`) on a protected branch, ideally with a GitHub [environment](https://docs.github.com/en/actions/deployment/targeting-different-environments/using-environments-for-deployment) holding the SSH secrets. Never use `pull_request_target` with this action or pass an untrusted `github.head_ref` as `branch`: anyone who can change the workflow or the deployed branch can run code on your server.
- **Pin the action.** `@v5` is a mutable tag. For production, pin to a full commit SHA (`uses: notcoffee418/docker-compose-deploy-action@<sha> # v5`).
- **Pin the server's host key.** Set `ssh_known_hosts` to the output of `ssh-keyscan -p <port> <host>`, run from a network you trust, and store it as a secret. If it is empty, the action fetches the host key at deploy time and warns, because that cannot detect a man-in-the-middle.
- **Prefer keys over passwords.** Use a dedicated, passphrase-less key that is only authorized for the deploy user. `ssh_password` needs `sshpass` and is supported only for compatibility. If both are set, the password is used.
- **Least privilege on the server.** The deploy user can run Docker, which is effectively root. Do not reuse that account for anything else.
- **Inputs are validated.** `ssh_host`, `ssh_user`, `ssh_port`, `repository`, `branch` and `docker_compose_file` are checked against strict patterns, and every value is shell-quoted before it reaches the server. Only deploy branches/repositories you trust, since their compose file runs on your server.
- **Deploy order:** the branch is fetched first (a failure here leaves the running stack untouched), then the stack is stopped with the *currently deployed* compose file, then the new code is checked out and started. A failing `docker compose down` only logs a warning.

## Requirements and behavior notes

- The script is sent to the server's login shell over SSH, so `docker` must be on the deploy user's login `PATH` and the login shell must be POSIX-compatible (bash, zsh, dash, ...; not fish/csh).
- `ssh_deployer_path` may start with `~/`, `$HOME/` or `${HOME}/`; other shell expansions are not performed. Paths with spaces are supported.
- `docker_compose_file` is a single file path. To use several compose files, use a single file with `include:` or set `COMPOSE_FILE` on the server.
- The runner needs an `ssh` client (all GitHub-hosted Linux/macOS runners have one).

## Accessing Private Repositories

To give your server access to your GitHub repositories using SSH keys, follow these steps:

1. **Generate SSH Key Pair on Deployment Server:**
   ```bash
   su YOUR_DEPLOYER_USER
   mkdir -p ~/.ssh/github-keys
   ssh-keygen -t ed25519 -C "deploy@your-server" -f ~/.ssh/github-keys/id_ed25519 -N ""
   chmod 400 ~/.ssh/github-keys/id_ed25519
   ```

2. **Add Public Key to GitHub:**
   - Copy the public key:
     ```bash
     cat ~/.ssh/github-keys/id_ed25519.pub
     ```
   - Go to your repository on GitHub > Settings > Deploy keys.
   - Click "Add deploy key" and paste your public key as authentication key. Leave "Allow write access" **unchecked**.

3. **Configure Git to Use the SSH Key:**
   - Edit your SSH configuration file (`~/.ssh/config`) to use the new key for GitHub:
    ```bash
    echo -e "Host github.com\n  IdentityFile ~/.ssh/github-keys/id_ed25519\n  User git" >> ~/.ssh/config
    chmod 600 ~/.ssh/config
    ```
   - Test the connection and approve fingerprint on first time connecting:
    ```bash
    ssh -T git@github.com
    # Compare the fingerprint with https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints before typing "yes"
    ```


## Contributing

If you have suggestions for how this GitHub Action could be improved, or want to report a bug, please open an issue or a pull request in this repository.

## License

This GitHub Action is licensed under the [MIT License](LICENSE).
