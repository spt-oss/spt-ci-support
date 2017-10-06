# SPT CI Support

[![circleci](https://img.shields.io/badge/circleci-spt--ci--support-brightgreen.svg)](https://circleci.com/gh/spt-oss/spt-build-scripts)

* CI support for Docker, Java, Maven, Amazon ECS, etc.
* The scripts have been tested in [CircleCI 1.0](https://circleci.com/docs/1.0/docker/) and [CircleCI 2.0 Pre-Built Docker Images ( Java / Node.js )](https://circleci.com/docs/2.0/circleci-images/).
* This project is in the experimental stage.

## TOC

* [Products](#products)
* [Usage](#usage)
	* [Update AWS CLI in CircleCI](#update-aws-cli-in-circleci)
	* [Update Docker in CircleCI](#update-docker-in-circleci)
	* [Update Maven in CircleCI](#update-maven-in-circleci)
	* [Install Brotli](#install-brotli)
	* [Install Zopfli](#install-zopfli)
	* [Install New Relic for Java](#install-new-relic-for-java)
	* [Install GPG key](#install-gpg-key)
	* [Upload Docker image to Amazon ECR](#upload-docker-image-to-amazon-ecr)
	* [Update Docker task in Amazon ECS](#update-docker-task-in-amazon-ecs)
	* [Refine Maven build in CircleCI](#refine-maven-build-in-circleci)
* [License](#license)

## Products

* Installer

	| Name                        | Short URL             | Reference                                                                                                          |
	| ---                         | ---                   | ---                                                                                                                |
	| install-circleci-aws-cli.sh | https://goo.gl/TxRMcu | [AWS CLI](https://github.com/aws/aws-cli)                                                                          |
	| install-circleci-docker.sh  | https://goo.gl/sqB5kK | [circleci/docker](https://github.com/circleci/docker)                                                              |
	| install-circleci-maven.sh   | https://goo.gl/SjUH1i | [Maven](https://maven.apache.org/)                                                                                 |
	| install-brotli.sh           | https://goo.gl/NDPcpi | [Brotli](https://github.com/google/brotli)                                                                         |
	| install-zopfli.sh           | https://goo.gl/qqsPUK | [Zopfli](https://github.com/google/zopfli)                                                                         |
	| install-newrelic-jar.sh     | https://goo.gl/VZYNYT | [New Relic for Java](https://docs.newrelic.com/docs/agents/java-agent/getting-started/introduction-new-relic-java) |
	| install-gpg-key.sh          | https://goo.gl/dPhYzo | [PGP Signatures with Maven](http://blog.sonatype.com/2010/01/how-to-generate-pgp-signatures-with-maven/)           |
	| install-command.sh          | https://goo.gl/PcfcFG | -                                                                                                                  |

* Command

	| Name        | Reference                                                                                      |
	| ---         | ---                                                                                            |
	| ecr-upload  | [Amazon ECR](http://docs.aws.amazon.com/AmazonECR/latest/userguide/docker-push-ecr-image.html) |
	| ecs-deploy  | [spt-oss/ecs-deploy](https://github.com/spt-oss/ecs-deploy)                                    |
	| git-*       | [Git](https://git-scm.com/)                                                                    |
	| mvn-*       | [Maven](https://maven.apache.org/)                                                             |

## Usage

### Update AWS CLI in CircleCI

* CircleCI 2.0

    ```yaml
    - run: curl -fsSL https://goo.gl/TxRMcu | bash
    ```

* CircleCI 1.0

    ```yaml
    machine:
        pre:
            - curl -fsSL https://goo.gl/TxRMcu | bash
    ```

### Update Docker in CircleCI

* CircleCI 1.0

    ```yaml
    machine:
        pre:
            - curl -fsSL https://goo.gl/sqB5kK | bash -s -- 1.10.0  # <1.9.0~1.10.0>
    ```

### Update Maven in CircleCI

* CircleCI 2.0

    ```yaml
    - run: curl -fsSL https://goo.gl/SjUH1i | bash -s -- 3.5.0  # <3.0.4~>
    ```

* CircleCI 1.0

    ```yaml
    machine:
        pre:
            - curl -fsSL https://goo.gl/SjUH1i | bash -s -- 3.5.0  # <3.0.4~>
    ```

### Install Brotli

* Any CI

    ```bash
    $ curl -fsSL https://goo.gl/NDPcpi | bash -s -- ~/.foo  # <cache-directory>
    ```

* CircleCI 2.0

    ```yaml
    - restore_cache:
        keys:
            - XXXXXXXXXX
    - run: curl -fsSL https://goo.gl/NDPcpi | bash -s -- ~/.foo  # <cache-directory>
    - save_cache:
        paths:
            - ~/.foo
        key: XXXXXXXXXX
    ```

* CircleCI 1.0

    ```yaml
    dependencies:
        post:
            - curl -fsSL https://goo.gl/NDPcpi | bash -s -- ~/.foo  # <cache-directory>
    ```

### Install Zopfli

* Any CI

    ```bash
    $ curl -fsSL https://goo.gl/qqsPUK | bash -s -- ~/.foo  # <cache-directory>
    ```

* CircleCI 2.0

    ```yaml
    - restore_cache:
        keys:
            - XXXXXXXXXX
    - run: curl -fsSL https://goo.gl/qqsPUK | bash -s -- ~/.foo  # <cache-directory>
    - save_cache:
        paths:
            - ~/.foo
        key: XXXXXXXXXX
    ```

* CircleCI 1.0

    ```yaml
    dependencies:
        post:
            - curl -fsSL https://goo.gl/qqsPUK | bash -s -- ~/.foo  # <cache-directory>
    ```

### Install New Relic for Java

* Any CI

	```bash
	$ curl -fsSL https://goo.gl/VZYNYT | bash -s -- ~/.foo  # <jar-file-directory>
	```

### Install GPG key

1. Generate GPG keys ( `pubring.gpg` and `secring.gpg` ) and encrypt them with OpenSSL AES-256-CBC.

	```bash
	$ openssl aes-256-cbc -md sha256 -in pubring.gpg -out pubring.gpg.enc -k <encrypt-password>
	$ openssl aes-256-cbc -md sha256 -in secring.gpg -out secring.gpg.enc -k <encrypt-password>
	```

1. Upload the encrypted keys ( `pubring.gpg.enc` and `secring.gpg.enc` ) to the global web in the same path.

	```bash
	https://example.com/path/pubring.gpg.enc
	https://example.com/path/secring.gpg.enc
	```

1. Execute the following command to download keys in `${HOME}/.gnupg`.

	```bash
	$ PUB_URL=https://example.com/path/pubring.gpg.enc  # <encrypted-pubring-url:public>
	$ ENC_PASS=XXXXXXXXXX                               # <encrypt-password:secret>
	
	$ curl -fsSL https://goo.gl/dPhYzo | bash -s -- ${PUB_URL} ${ENC_PASS}
	```

### Upload Docker image to Amazon ECR

1. Install `ecr-upload` command.

	```bash
	$ curl -fsSL https://goo.gl/PcfcFG | bash -s -- /usr/local/bin  # <directory-in-path>
	```

1. Configure the AWS CLI.

	```bash
	$ aws configure
	```

1. Run `ecr-upload` command. The arguments of `ecr-upload` are mostly the same as [docker build](https://docs.docker.com/engine/reference/commandline/build/).

	```bash
	$ ecr-upload -t 123456789.dkr.ecr.us-west-1.amazonaws.com/my-app:latest --rm=false .
	```

	| Improved Argument | Description                  |
	| ---               | ---                          |
	| -t                | `<ecr-repository-uri>:<tag>` |

### Update Docker task in Amazon ECS

1. Install `ecs-deploy` command.

	```bash
	$ curl -fsSL https://goo.gl/PcfcFG | bash -s -- /usr/local/bin  # <directory-in-path>
	```

1. Configure the AWS CLI.

	```bash
	$ aws configure
	```

1. Run `ecs-deploy` command. The arguments of `ecs-deploy` are mostly the same as [ecs-deploy](https://github.com/spt-oss/ecs-deploy).

	```bash
	$ ecs-deploy -i 123456789.dkr.ecr.us-west-1.amazonaws.com/my-app:latest -c my-app-cluster -n my-app -ldn
	```

	| Additional Argument | Description                                                            |
	| ---                 | ---                                                                    |
	| -ldn                | Detect the latest task definition (Use the service name as the family) |

### Refine Maven build in CircleCI

* See the examples below.
	* [spt-oss/spt-java-parent](https://github.com/spt-oss/spt-java-parent)

## License

* This software is released under the Apache License 2.0.
