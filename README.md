# Pulpsak

pulpsak is an incomplete but usable command line interface to
[pulp3](https://pulpproject.org/about-pulp-3/).  Only some core task
related functions and a selection of rpm plugin functions are
supported and not even all of those.  When pulpsak was started I was
unaware of the [pulp-cli](https://github.com/pulp/pulp-cli) project
and so went about implementing the commands needed for what I was
trying to accomplish with pulp3.  As a result I may not continue work
on pulpsak, preferring to put any time into the pulp-cli project.

I will attempt to document here what pulpsak does do currently.

## Installation

pulpsak provides an executable of the same name, not a library
suitable for use in other applications


```bash
gem install pulpsak
```

## Usage
    $ pulpsak
    Commands:
      pulpsak help [COMMAND]  # Describe available commands or one specific command
      pulpsak rpm             # manage rpm plugins
      pulpsak tasks           # list/manage tasks

### tasks
    $ pulpsak tasks
    Commands:
      pulpsak tasks cancel [PULP_HREF]   # cancel task by uuid
      pulpsak tasks help [COMMAND]       # Describe subcommands or one specific subcommand
      pulpsak tasks inspect [PULP_HREF]  # inspect task by uuid
      pulpsak tasks list                 # list all tasks
      pulpsak tasks wait [PULP_HREF]     # monitor task progress by uuid

#### tasks list
Outputs an unfiltered list of all tasks known to pulp.  Since there is
no meaniningful way to refer to a task except to use the href, it is
output as well.

    $ pulpsak tasks list
    +----------------------------------------------+-----------+---------------------------+---------------------------+----------------------------------------------------------+
    |                     name                     |   state   |          started          |         finished          |                        pulp_href                         |
    +----------------------------------------------+-----------+---------------------------+---------------------------+----------------------------------------------------------+
    | pulpcore.app.tasks.base.general_update       | completed | 2021-06-29T18:29:18+00:00 | 2021-06-29T18:29:34+00:00 | /pulp/api/v3/tasks/52114e7c-1a34-4168-9aa5-15a41dd2b078/ |
    | pulpcore.app.tasks.base.general_update       | completed | 2021-06-29T18:27:08+00:00 | 2021-06-29T18:27:08+00:00 | /pulp/api/v3/tasks/1d840660-a73c-4ac0-beaf-a4eb8fa82b50/ |
    ...
    +----------------------------------------------+-----------+---------------------------+---------------------------+----------------------------------------------------------+

#### tasks inspect
Show the output in json of calling inspect on the given pulp task href.

    $ pulpsak tasks inspect /pulp/api/v3/tasks/71d39f53-f6cd-4ac3-a908-4e4c4539a6b5/
    #<PulpcoreClient::TaskResponse:0x000055f0f0267f50
     @child_tasks=[],
     @created_resources=[],
     @finished_at=
      #<DateTime: 2021-06-17T16:41:25+00:00 ((2459383j,60085s,961928000n),+0s,2299161j)>,
     @logging_cid="b45263e2db69498c9b342d3a921c282f",
     @name="pulpcore.app.tasks.base.general_update",
     @progress_reports=[],
     @pulp_created=
      #<DateTime: 2021-06-17T16:41:25+00:00 ((2459383j,60085s,553948000n),+0s,2299161j)>,
     @pulp_href="/pulp/api/v3/tasks/71d39f53-f6cd-4ac3-a908-4e4c4539a6b5/",
     @reserved_resources_record=["/api/v3/distributions/"],
     @started_at=
      #<DateTime: 2021-06-17T16:41:25+00:00 ((2459383j,60085s,702051000n),+0s,2299161j)>,
     @state="completed",
     @worker="/pulp/api/v3/workers/25e6ca70-0fc6-41f3-b3a9-10316bd34122/">

#### tasks wait
Poll the status of a task that is "running" or "waiting" until it is no longer either of those things, then print the result of the final inspection of the task.

    $ pulpsak tasks wait /pulp/api/v3/tasks/71d39f53-f6cd-4ac3-a908-4e4c4539a6b5/
    
    #<PulpcoreClient::TaskResponse:0x0000556de1ca8880
     @child_tasks=[],
     @created_resources=[],
     @finished_at=
      #<DateTime: 2021-06-17T16:41:25+00:00 ((2459383j,60085s,961928000n),+0s,2299161j)>,
     @logging_cid="b45263e2db69498c9b342d3a921c282f",
     @name="pulpcore.app.tasks.base.general_update",
     @progress_reports=[],
     @pulp_created=
      #<DateTime: 2021-06-17T16:41:25+00:00 ((2459383j,60085s,553948000n),+0s,2299161j)>,
     @pulp_href="/pulp/api/v3/tasks/71d39f53-f6cd-4ac3-a908-4e4c4539a6b5/",
     @reserved_resources_record=["/api/v3/distributions/"],
     @started_at=
      #<DateTime: 2021-06-17T16:41:25+00:00 ((2459383j,60085s,702051000n),+0s,2299161j)>,
     @state="completed",
     @worker="/pulp/api/v3/workers/25e6ca70-0fc6-41f3-b3a9-10316bd34122/">

#### tasks cancel
Attempts to cancel a task, doesn't work probably due to a
misunderstanding on my part of the API, or a mismatch between the
version of pulp3 I am testing on and the generated api.

### rpm
    $ pulpsak rpm
    Commands:
      pulpsak rpm distributions   # manage distributions
      pulpsak rpm help [COMMAND]  # Describe subcommands or one specific subcommand
      pulpsak rpm publications    # manage publications
      pulpsak rpm remotes         # manage remotes
      pulpsak rpm repositories    # manage repositories

#### rpm remotes
    $ pulpsak rpm remotes
    Commands:
      pulpsak remotes create [NAME] [URL]  # create remote
      pulpsak remotes delete [NAME]        # delete a remote
      pulpsak remotes help [COMMAND]       # Describe subcommands or one specific subcommand
      pulpsak remotes list                 # list all remotes
      pulpsak remotes update [NAME]        # update remote

##### rpm remotes create
    $ pulpsak rpm remotes help create
    Usage:
      pulpsak remotes create [NAME] [URL]
    
    Options:
      [--ca-cert=CA_CERT]                        # A PEM encoded CA certificate used to validate the server certificate presented by the remote server.
      [--client-cert=CLIENT_CERT]                # A PEM encoded client certificate used for authentication.
      [--client-key=CLIENT_KEY]                  # A PEM encoded private key used for authentication.
      [--tls-validation], [--no-tls-validation]  # If True, TLS peer validation must be performed.
      [--proxy-url=PROXY_URL]                    # The proxy URL. Format: scheme://user:password@host:port
      [--username=USERNAME]                      # The username to be used for authentication when syncing.
      [--password=PASSWORD]                      # The password to be used for authentication when syncing.
      [--download-concurrency=N]                 # Total number of simultaneous connections.
      [--policy=POLICY]                          # The policy to use when downloading content. The possible values include: 'immediate', 'on_demand', and 'streamed'. 'immediate' is the default.
      [--sles-auth-token=SLES_AUTH_TOKEN]        # Authentication token for SLES repositories.

    $ pulpsak rpm remote create test-rem http://some.example.com/yum --download-concurrency=2 
    #<PulpRpmClient::RpmRpmRemoteResponse:0x000055b95c676748
     @download_concurrency=2,
     @name="test-rem",
     @policy="immediate",
     @pulp_created=
      #<DateTime: 2021-06-30T14:07:57+00:00 ((2459396j,50877s,905737000n),+0s,2299161j)>,
     @pulp_href=
      "/pulp/api/v3/remotes/rpm/rpm/dc90b878-2fae-4439-b889-40b1531e67e8/",
     @pulp_last_updated=
      #<DateTime: 2021-06-30T14:07:57+00:00 ((2459396j,50877s,905762000n),+0s,2299161j)>,
     @tls_validation=true,
     @url="http://some.example.com/yum">

##### rpm remotes delete 
    $ pulpsak rpm remote help delete
    Usage:
      pulpsak remotes delete [NAME]
    
    delete a remote

    $ pulpsak rpm remote delete test-rem
    #<PulpRpmClient::AsyncOperationResponse:0x000055f40c7b6730
     @task="/pulp/api/v3/tasks/faaa6a20-1cd4-497d-94e9-b2d418f11860/">

##### rpm remotes list

    $ pulpsak rpm remote list
    +---------------------------+--------------------------------------------+----------------------------------------------------------------------------------------+----------------------+-----------+
    |        last update        |                    name                    |                                          url                                           | download_concurrency |  policy   |
    +---------------------------+--------------------------------------------+----------------------------------------------------------------------------------------+----------------------+-----------+
    | 2021-06-16 20:03:53 +0000 | fedora-33-x86_64-everything                | https://mirrors.uiowa.edu/pub/fedora/releases/33/Everything/x86_64/os/                 | 10                   | immediate |
    | 2021-06-16 20:03:26 +0000 | fedora-33-x86_64-updates                   | https://mirrors.uiowa.edu/pub/fedora/updates/33/Everything/x86_64/                     | 10                   | immediate |
    ...
    | 2021-06-16 20:00:50 +0000 | fedora-33-x86_64-rpmfusion-free-updates    | https://download1.rpmfusion.org/free/fedora/updates/33/x86_64/                         | 10                   | immediate |
    | 2021-06-16 20:00:11 +0000 | fedora-33-x86_64-rpmfusion-nonfree-updates | https://download1.rpmfusion.org/nonfree/fedora/updates/33/x86_64/                      | 10                   | immediate |
    +---------------------------+--------------------------------------------+----------------------------------------------------------------------------------------+----------------------+-----------+

    $ pulpsak rpm remote update test-rem --download-concurrency=5 --policy on_demand
    updating remote test-rem

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/pulpsak.

