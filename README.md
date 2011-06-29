Git Log Relay Chat
==================

What is this
------------

git-log-relay-chat is a chat system based on `git`. Chat members fork from one common repository to their own local repo, talk by `git-commit`'s commit message, and `git-pull`-ing each other to retrieve others' message. Each chat session is indivisual repo (with some ancestor), `git-merge`-ing them glues sessions together.

Installation
------------

	# git clone git://github.com/motemen/git-log-relay-chat.git
	# cd git-log-relay-chat

Then clone your repository for chatting (ex. gist). Thorugh others' forks of the repo, you can do chat.

Configuration
-------------

Configure manually for example:

	# # config.pl
	# git_root => 'gist-1050889', # your local clone
	# pull_remote => [
	#     'git://gist.github.com/1050895.git', # sibling fork's public clone URL
	#     'git://gist.github.com/1050896.git', # ditto
	#     'git://gist.github.com/1050905.git', # ditto
	# ],

Or generate by script:

	# perl make-config.pl [your-forked-id] > config.pl
	# vi config.pl

Usage
-----

    # plackup

Chat Start Guide
----------------

### Join existing chat

Fork existing repo and clone it to local. Specify your local repo as `git_root` in config.pl. Add other's public clone URL to `pull_remote` in config.pl to pull other members' messages.
Do not forget to tell other members to add your public clone URL to `pull_remote` in config.pl so that they can pull your message.

### Star new chat

Create some new repository (ex. gist). Clone this to local, and specify this as `git_root` in config.pl.
New member should follow the "join existing chat" instruction, and you should add their public clone URL to `pull_remote` in config.pl.
