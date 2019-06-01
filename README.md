# Multiple Git identities

This repo contains a Python script called `git-identity`. It manages some symlinks in your home directory and in your `.ssh` directory to allow you to switch between Git identities with different SSH keys and email addresses.

Consider the case where you have a Github account for personal use and a Github account for work use. We'll call these accounts, or identities, `personal` and `work`. This solution will scale to arbitrarily many identities, but to keep things simple, we'll keep it to two in the examples here.

Using `git-identity`, with one command you can set which identity will currently be used by Git.

To use your `work` identity, run:

    $ git identity use work

To use your `personal` identity, run:

    $ git identity use personal

## Installation

Copy the `git-identity` script to a directory on your `PATH`.

## Setup

You'll need to set up SSH keys for each of your identities. They will be saved in your `.ssh` directory.

You'll also need to create a `gitconfig` fragment for each of your identities. They will be saved in your home directory.

This only needs to be done once per identity.

### Setting up your SSH keys

You'll need to have an SSH key for each Git identity. We'll use a fixed naming scheme to differentiate them. They will be stored in your `.ssh` directory. Their names will be `id_rsa_git_` followed by the identity name. Consider the case where you have an identity for personal use and for work use. We'll call these identities `personal` and `work`.

    $ cd ~/.ssh

    # Generate an SSH key for personal use:
    $ ssh-keygen -t rsa -C "personal@email.address"
    # Save this key to id_rsa_git_personal

    # Generate an SSH key for work use:
    $ ssh-keygen -t rsa -C "work@email.address"
    # Save this key to id_rsa_git_work

Once this is done, you should have the following files in `~/.ssh`:

- `id_rsa_git_personal`
- `id_rsa_git_personal.pub`
- `id_rsa_git_work`
- `id_rsa_git_work.pub`

You'll need to add the public keys to the appropriate Github (or other code hosting service) accounts. You can copy the public key to the clipboard via `pbcopy`. For example, to copy your `personal` public key, run the following:

    $ pbcopy < ~/.ssh/id_rsa_git_personal.pub

### Setting up your SSH config file

If you don't have a `~/.ssh/config` file, create one. Edit it to contain the following:

    # Default Github
    Host github.com
      HostName github.com
      User git
      IdentityFile ~/.ssh/id_rsa_git_current

This configures Git SSH URLs to use `~/.ssh/id_rsa_git_current.pub` and `~/.ssh/id_rsa_git_current` as your public and private SSH keys. _These files do not yet exist._ The `git-identity` script will create these as soft links to the currently-selected configuration's key files.

### Setting up your Git config

You likely already have a `~/.gitconfig` file in your home directory. Open it in a text editor. You should see a section in it that looks like this:

    [user]
        name = Your Name
        email = personal@email.address

We want to be able to switch the name and email address based on the current Git identity. So, replace those lines with the following:

    [include]
        path = ~/.gitconfig_identity_current

You'll need to have a `gitconfig` fragment for each Git identity. Again, we'll use a naming scheme to differentiate them. They will be stored in your home directory. Their names will be `.gitconfig_identity_` followed by the identity name. Continuing our example of `personal` and `work` identities:

Create `~/.gitconfig_identity_personal` with the following:

    [user]
        name = Your Name
        email = personal@email.address

Create `~/.gitconfig_identity_work` with the following:

    [user]
        name = Your Name
        email = work@email.address

Now, your `~/.gitconfig` file includes a config file that does not yet exist. As above, the `git-identity` script will create these as softlinks to the current configuration's key files.

## Usage

To list the currently available identities, run:

    $ git identity
      personal
    * work

Here, we have two identities: `personal` and `work`. The `*` indicates that the work identity is currently selected. You can also run `git identity list` to get the same result.

To get the current Git identity, run:

    $ git identity current
      work

Here, the `work` identity is printed, indicating it's the currently-selected identity.

To change the current Git identity, run:

    $ git identity use personal

Verify that the change worked by running:

    $ git identity current
      personal

You can show more detailed information by running:

    $ git identity print
    Current Git identity: personal

    User entries in `git config`
    ----------------------------
    user.name=Your Name
    user.email=personal@email.address

## Testing SSH Keys

You can verify that SSH is configured correctly by connecting via SSH to your Git hosting service. (This has been verified to work with Github and Bitbucket. Your mileage may vary for other services.)

For example, let's say your `work` identity is associated with a Github account named `My-Work-Account`. This is done by adding your `~/.ssh/id_rsa_git_work.pub` key with that account via the Github web interface. Let's also say your `personal` identity is associated with a Github account named `My-Personal-Account`. This is done by adding your `~/.ssh/id_rsa_git_personal.pub` key with that account via the Github web interface.

You can verify the account associated with your identity by running the following:

    $ git identity use work

    $ ssh github.com
    PTY allocation request failed on channel 0
    Hi My-Work-Account! You've successfully authenticated, but GitHub does not provide shell access.
    Connection to github.com closed.

    $ git identity use personal

    $ ssh github.com
    PTY allocation request failed on channel 0
    Hi My-Personal-Account! You've successfully authenticated, but GitHub does not provide shell access.
    Connection to github.com closed.
