# Git Identity

Juggling multiple remote Git accounts is a hassle. This project provides tools that allow you to easily switch between these accounts. You need to do some initial setup described below. The tools then create and manage some symlinks in your home directory and in your `.ssh` directory which point to the configuration for the currently selected identity.

Consider the case where you have a Github account for personal use and a Github account for work use. We'll call these accounts, or identities, `personal` and `work`. This solution will scale to arbitrarily many identities, but to keep things simple, we'll keep it to two in the examples here.

This repo contains two Swift applications for managing your Git identity:

- A CLI application called `git-identity`. Installing this on your path allows you to run `git identity` commands as described below.
- A macOS GUI application called `GitIdentity`. This is a status bar app that allows you to see your current identity at a glance and to change identies with a click on the mouse.

Using `git-identity`, with one command you can set which identity will currently be used by Git.

To use your `work` identity, run:

    $ git identity use work

To use your `personal` identity, run:

    $ git identity use personal

## Installation

- Clone this repo and open the `xcodeproj` file.
- In the Project Navigator, select the `GitIdentity` project file.
- Under the `GitIdentity` and `git-identity` targets, set the signing team.
- Select the `git-identity` scheme and archive (from the Project > Archive menu). This will build and install the CLI binary to `/usr/local/bin`.
- Select the `GitIdentity` scheme and archive (from the Project > Archive menu). This will build and install the GUI binary to `~/Applications`.

## Setup

For each of your identities, you'll need to do the following:

- Set up SSH keys and save them in your `.ssh` directory.
- Create a `.gitconfig` fragment and save it in your home directory.

Finally, you'll need to create a configuration JSON file indicating what the identities are and where the SSH keys and `.gitconfig` fragments are stored.

### Setting up your SSH keys

You'll need to have an SSH key for each Git identity. We'll use a fixed naming scheme to differentiate them. They will be stored in your `.ssh` directory. In this example, their names will be `id_rsa_git_` followed by the identity name, but you are free to use whatever naming convention you prefer. Consider the case where you have an identity for personal use and for work use. We'll call these identities `personal` and `work`.

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

This configures Github SSH URLs to use `~/.ssh/id_rsa_git_current.pub` and `~/.ssh/id_rsa_git_current` as your public and private SSH keys. _These files do not yet exist._ The `git-identity` script will create these as symbolic links to the currently-selected identity's key files.

You will need to have similar configuration entries for other Git hosts.

### Setting up your Git config

You likely already have a `~/.gitconfig` file in your home directory. Open it in a text editor. You should see a section in it that looks like this:

    [user]
        name = Your Name
        email = personal@email.address

We want to be able to switch the name and email address based on the current Git identity. So, replace those lines with the following:

    [include]
        path = ~/.gitconfig_identity_current

Now, your `~/.gitconfig` file includes a config file that does not yet exist. As above, the `git-identity` script will create these as symbolic links to the current configuration's key files.

You'll need to have a `gitconfig` fragment for each Git identity. They will be stored in your home directory. Their names will be `.gitconfig_identity_` followed by the identity name, but you are free to use whatever naming convention you prefer. Continuing our example of `personal` and `work` identities:

Create `~/.gitconfig_identity_personal` with the following:

    [user]
        name = Your Name
        email = personal@email.address

Create `~/.gitconfig_identity_work` with the following:

    [user]
        name = Your Name
        email = work@email.address

### Setting up your Git Identity config

Finally, you will need to create a JSON file in your home directory named `.git-identity-config.json`:

    {
        "current": {
            "gitconfig": "~/.gitconfig_identity_current",
            "privateKey": "~/.ssh/id_rsa_git_current",
            "publicKey": "~/.ssh/id_rsa_git_current.pub"
        },
        "personal": {
            "gitconfig": "~/.gitconfig_identity_personal",
            "privateKey": "~/.ssh/id_rsa_git_personal",
            "publicKey": "~/.ssh/id_rsa_git_personal.pub"
        },
        "work": {
            "gitconfig": "~/.gitconfig_identity_work",
            "privateKey": "~/.ssh/id_rsa_git_work",
            "publicKey": "~/.ssh/id_rsa_git_work.pub"
        }
    }

In the example above we have listed the following:

- A `current` configuration. This contains the paths you added in the setup steps above:
    - The `gitconfig` file is the path you included in your `.gitconfig` file's `[include]` section.
    - The `privateKey` file is the path you included in your `.ssh/config` file.
    - The `publicKey` file is the path to the public key associated with the private key. It should be the name of the private key file with `.pub` at the end.
- Two other configurations: `personal` and `work` using the file paths created above.

## Usage

The first step will be to set the current identity. Run the following:

    $ git identity use work

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

    Git config contents:
    --------------------
    [user]
        name = Your Name
        email = personal@email.address

    Public key:
    -----------
    ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC5iRLTyBal1owgzE6M+/tLxPIEtqd9yT1vI/kk2ykM0KFUac8WCI65YId28t8hOVxP+AufAdeVXaSr4ZuVl9BPgwpo7ZS1ls8GW5prxkArmwG2MuJkQS1AipJ53Zng0w2DF0oCa/FcusSxz5y7nvAdcLM5cYJoAjWdhluQ0loe1m8KJM2Bl0A/2tpfsi1vHugvds4d9T6q4uYqImaWJ4hOuRot52ygDyN/i3IsqTVVzDae7q0F9TCjvBA1QGbo8Km6uUGN5wNi6fcLgsxdezITQNVChvFvLVRi5ve5l+BhdprDwUnpxVdwkNa1U2Tyu6cRnxwLnYo5WliBgAWrxFz3 personal@email.address

## GUI

There is an optional macOS status bar app. It shows a Git icon along with the current identity in the status bar. Clicking on the status bar item pops up a menu containing your available Git identities. A checkmark will be next to the current identity in the list.

The GUI interoperates with the command-line tool. So long as you use the command-line tool to change the current identity the GUI will automatically update.

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
    Connection to github.com closed.kl

## Credits

The `GitIdentity` GUI application uses the [Git logo](https://git-scm.com/downloads/logos) by [Jason Long](https://twitter.com/jasonlong) and is licensed under the [Creative Commons Attribution 3.0 Unported License](https://creativecommons.org/licenses/by/3.0/).

