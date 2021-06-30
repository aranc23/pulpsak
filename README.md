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

## Workflow

### Create a remote
    $ pulpsak rpm remote create virtualgl-remote https://sourceforge.net/projects/virtualgl/files
    #<PulpRpmClient::RpmRpmRemoteResponse:0x0000561e2fb3aad0
     @download_concurrency=10,
     @name="virtualgl-remote",
     @policy="immediate",
     @pulp_created=
      #<DateTime: 2021-06-30T15:40:37+00:00 ((2459396j,56437s,878776000n),+0s,2299161j)>,
     @pulp_href=
      "/pulp/api/v3/remotes/rpm/rpm/d5aa8535-a116-4500-9d3b-02a736946cd4/",
     @pulp_last_updated=
      #<DateTime: 2021-06-30T15:40:37+00:00 ((2459396j,56437s,878797000n),+0s,2299161j)>,
     @tls_validation=true,
     @url="https://sourceforge.net/projects/virtualgl/files">
    
    $ pulpsak rpm remote list|grep -i virtualgl
    | 2021-06-30 15:40:37 +0000 | virtualgl-remote                           | https://sourceforge.net/projects/virtualgl/files                                       | 10                   | immediate |

### create a repo using the remote
    $ pulpsak rpm repo create virtualgl-repo --remote virtualgl-remote
    #<PulpRpmClient::RpmRpmRepositoryResponse:0x00005571c6a263d0
     @latest_version_href=
      "/pulp/api/v3/repositories/rpm/rpm/3f029ad5-f0aa-4afc-a8d8-8e731ce4b1c8/versions/0/",
     @name="virtualgl-repo",
     @pulp_created=
      #<DateTime: 2021-06-30T15:43:54+00:00 ((2459396j,56634s,547928000n),+0s,2299161j)>,
     @pulp_href=
      "/pulp/api/v3/repositories/rpm/rpm/3f029ad5-f0aa-4afc-a8d8-8e731ce4b1c8/",
     @remote="/pulp/api/v3/remotes/rpm/rpm/d5aa8535-a116-4500-9d3b-02a736946cd4/",
     @retain_package_versions=0,
     @versions_href=
      "/pulp/api/v3/repositories/rpm/rpm/3f029ad5-f0aa-4afc-a8d8-8e731ce4b1c8/versions/">
    
    $ pulpsak rpm repo list |grep virtual
    | 2021-06-30 15:43:54 +0000 | virtualgl-repo                             | 0    | https://sourceforge.net/projects/virtualgl/files                                   |

### create a distribution and related publication

    $ pulpsak rpm dist create virtualgl-dist virtualgl virtualgl-repo --version 0 
    creating new publication....
    creating distribution.
    $ pulpsak rpm dist list
    +---------------------------+----------------------------------------------------+----------------------------------------------------+----------------------------------------------+----------+---------------+----------+---------+
    |          created          |                        name                        |                        base                        |                  pub->repo                   | gpgcheck | repo_gpgcheck | metadata | package |
    +---------------------------+----------------------------------------------------+----------------------------------------------------+----------------------------------------------+----------+---------------+----------+---------+
    | 2021-06-30 15:46:32 +0000 | virtualgl-dist                                     | virtualgl                                          | virtualgl-repo:0                             | 0        | 0             | sha256   | sha256  |
    +---------------------------+----------------------------------------------------+----------------------------------------------------+----------------------------------------------+----------+---------------+----------+---------+

This will publish the virtualgl repo at
http://<yourhost>/pulp/content/virtualgl/ unless you're configured it
otherwise.  However, since we never called sync the repo will be
empty.

### sync a repo

    $ pulpsak rpm repo sync virtualgl-repo

This will create a new version of the virtualgl-repo, containing the
rpms it found at the specified remote.  It will not update the
distribution we created, because that distribution is using the
initial and empty version of the repository.  To publish the updated
repo, we need to create a publication and associate it with the
distribution.

    $ pulpsak rpm repo ver list virtualgl-repo
    +---------------------------+--------+-------+---------+---------+
    |          created          | number | added | present | removed |
    +---------------------------+--------+-------+---------+---------+
    | 2021-06-30 15:51:51 +0000 | 1      | 1     | 1       | 0       |
    | 2021-06-30 15:43:54 +0000 | 0      | 0     | 0       | 0       |
    +---------------------------+--------+-------+---------+---------+

### update the distribution to use the newly sync'ed repo
    $ pulpsak rpm dist update virtualgl-dist --version 1
    creating new publication..
    updating distribution. complete

We can also use a negative number for the version, to specify the nth
most recent repo version:

    $ pulpsak rpm dist update virtualgl-dist --version -1
    updating distribution. complete

### sync and update the repo and distribution with one command

There is no "sync" command for distributions, but the pulpsak dist
sync command will sync the repo associated with a distribution, create
a new publication for that repo and associate it with the distribution:

    $ pulpsak rpm dist sync virtualgl-dist 
    syncing virtualgl-repo (you can ctrl-c out, it will continue in the background)
    ..
    #<PulpcoreClient::TaskResponse:0x000055ad270967d8
     @child_tasks=[],
     @created_resources=[],
     @finished_at=
      #<DateTime: 2021-06-30T16:01:48+00:00 ((2459396j,57708s,202922000n),+0s,2299161j)>,
     @logging_cid="afb232fa27574f0a93b5f24bee8d1af5",
     @name="pulp_rpm.app.tasks.synchronizing.synchronize",
     @progress_reports=
      [#<PulpcoreClient::ProgressReportResponse:0x000055ad2705bf48
        @code="sync.optimizing",
        @done=1,
        @message="Optimizing Sync",
        @state="completed">],
     @pulp_created=
      #<DateTime: 2021-06-30T16:01:44+00:00 ((2459396j,57704s,444212000n),+0s,2299161j)>,
     @pulp_href="/pulp/api/v3/tasks/de30e087-00e2-40d2-bac1-075accbd2350/",
     @reserved_resources_record=
      ["/pulp/api/v3/repositories/rpm/rpm/3f029ad5-f0aa-4afc-a8d8-8e731ce4b1c8/",
       "/pulp/api/v3/remotes/rpm/rpm/d5aa8535-a116-4500-9d3b-02a736946cd4/"],
     @started_at=
      #<DateTime: 2021-06-30T16:01:44+00:00 ((2459396j,57704s,697527000n),+0s,2299161j)>,
     @state="completed",
     @worker="/pulp/api/v3/workers/cb78fe42-0431-4146-a4a3-9cd4b5ed6170/">
    updating distribution. complete
    
    
## Usage

pulpsak has usage information generated by thor and it should be
possible to start with just typing `pulpsak` and exploring from there.
Therefore, I won't be adding an example of each option and some
familiarity with the [pulp3 rpm
api](https://docs.pulpproject.org/pulp_rpm/restapi.html_ is required


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
#### rpm repositories
    $ pulpsak  rpm repositories
    Commands:
      pulpsak repositories create [NAME]   # create a repository
      pulpsak repositories delete [NAME]   # delete a repository
      pulpsak repositories help [COMMAND]  # Describe subcommands or one specific subcommand
      pulpsak repositories list            # list all repos
      pulpsak repositories sync [NAME]     # call sync on repo
      pulpsak repositories update [NAME]   # update a repository
      pulpsak repositories versions        # manage repository versions

##### rpm repositories list
    $ pulpsak  rpm repositories list
    +---------------------------+--------------------------------------------+------+------------------------------------------------------------------------------------+
    |          created          |                    name                    | keep |                                       remote                                       |
    +---------------------------+--------------------------------------------+------+------------------------------------------------------------------------------------+
    | 2021-06-16 20:03:54 +0000 | fedora-33-x86_64-everything                | 0    | https://mirrors.uiowa.edu/pub/fedora/releases/33/Everything/x86_64/os/             |
    | 2021-06-16 20:03:27 +0000 | fedora-33-x86_64-updates                   | 0    | https://mirrors.uiowa.edu/pub/fedora/updates/33/Everything/x86_64/                 |
    ...
    +---------------------------+--------------------------------------------+------+------------------------------------------------------------------------------------+

##### rpm repositories create
    $ pulpsak  rpm repositories help create
    Usage:
      pulpsak repositories create [NAME]
    
    Options:
      [--description=DESCRIPTION]                            # An optional description.
      [--retain-package-versions=N]                          # The number of versions of each package to keep in the repository; older versions will be purged. The default is '0', which will disable this feature and keep all versions of each package.
                                                             # Default: 0
      [--remote=REMOTE]                                      # name of existing remote
      [--metadata-signing-service=METADATA_SIGNING_SERVICE]  # A reference to an associated signing service.
    
    create a repository

##### rpm repositories sync
    $ pulpsak rpm repositories help sync 
    Usage:
      pulpsak repositories sync [NAME]
    
    Options:
      [--mirror], [--no-mirror]  # mirror true removes rpms, false is merely additive
      [--remote=REMOTE]          # mirror from alternate remote
    
    call sync on repo
    
    $ pulpsak  rpm repositories sync fedora-33-x86_64-cuda
    syncing fedora-33-x86_64-cuda (you can ctrl-c out, it will continue in the background)
    .Parsed Packages
    Downloading Artifacts
    Downloading Metadata Files
    Downloading Artifacts
    Downloading Metadata Files
    Downloading Artifacts
    
    #<PulpcoreClient::TaskResponse:0x000055ec8f5de0b8
     @child_tasks=[],
     @created_resources=
      ["/pulp/api/v3/repositories/rpm/rpm/6daa90a5-c1e6-41ba-9133-ffee4c8bb183/versions/2/"],
     @finished_at=
      #<DateTime: 2021-06-30T15:33:20+00:00 ((2459396j,56000s,356262000n),+0s,2299161j)>,
     @logging_cid="7830134bccfc44b1bf93edc0496f5c9d",
     @name="pulp_rpm.app.tasks.synchronizing.synchronize",
     @progress_reports=
      [#<PulpcoreClient::ProgressReportResponse:0x000055ec8f5caa68
        @code="sync.parsing.packages",
        @done=430,
        @message="Parsed Packages",
        @state="completed",
        @total=430>,
       #<PulpcoreClient::ProgressReportResponse:0x000055ec8f5ca270
        @code="sync.parsing.modulemds",
        @done=8,
        @message="Parsed Modulemd",
        @state="completed",
        @total=8>,
       #<PulpcoreClient::ProgressReportResponse:0x000055ec8f5c9078
        @code="sync.parsing.modulemd_defaults",
        @done=1,
        @message="Parsed Modulemd-defaults",
        @state="completed",
        @total=1>,
       #<PulpcoreClient::ProgressReportResponse:0x000055ec8f5b7918
        @code="sync.downloading.metadata",
        @done=5,
        @message="Downloading Metadata Files",
        @state="completed">,
       #<PulpcoreClient::ProgressReportResponse:0x000055ec8f5b7418
        @code="sync.downloading.artifacts",
        @done=86,
        @message="Downloading Artifacts",
        @state="completed">,
       #<PulpcoreClient::ProgressReportResponse:0x000055ec8f5b7008
        @code="associating.content",
        @done=95,
        @message="Associating Content",
        @state="completed">],
     @pulp_created=
      #<DateTime: 2021-06-30T15:31:19+00:00 ((2459396j,55879s,877192000n),+0s,2299161j)>,
     @pulp_href="/pulp/api/v3/tasks/90741e70-71de-474e-97b8-cd2879c450db/",
     @reserved_resources_record=
      ["/pulp/api/v3/remotes/rpm/rpm/21102dba-0fe5-41f6-af43-f130053989b2/",
       "/pulp/api/v3/repositories/rpm/rpm/6daa90a5-c1e6-41ba-9133-ffee4c8bb183/"],
     @started_at=
      #<DateTime: 2021-06-30T15:31:20+00:00 ((2459396j,55880s,129960000n),+0s,2299161j)>,
     @state="completed",
     @worker="/pulp/api/v3/workers/62ad3b81-654b-47ee-aeaf-61d9f291d95e/">

    
## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/pulpsak.

