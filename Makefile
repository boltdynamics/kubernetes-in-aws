SHELL = /bin/bash
SHELLFLAGS = -ex

# GIT_BRANCH ?= $(shell git rev-parse --abbrev-ref HEAD)
# VERSION ?= $(shell git rev-parse --short HEAD | cut -c1-7)

# Import settings and stage-specific overrides
include ./settings/defaults.conf
ifneq ("$(wildcard ./settings/$(ENVIRONMENT).conf"), "")
-include ./settings/$(ENVIRONMENT).conf
endif

CFN_ARTIFACT_BUCKET_NAME ?= $(CFN_ARTIFACT_BUCKET_NAME)

help:  ## Get help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(firstword $(MAKEFILE_LIST)) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
.PHONY: help

deploy-vpc: ## Deploy customer network factory - custom network step function
# ifndef GIT_BRANCH
# 	$(error GIT_BRANCH is undefined, define in parent shell)
# endif
	@aws cloudformation deploy \
		--s3-bucket $(CFN_ARTIFACT_BUCKET_NAME) \
	    --template-file cfn/vpc.yml \
		--stack-name pras-two-tier-vpc \
		--capabilities CAPABILITY_NAMED_IAM \
		--no-fail-on-empty-changeset \
		--parameter-overrides \
			VpcNetwork=$(VPC_NETWORK) \
			SubnetCidrs=$(SUBNET_CIDRS) \
		--tags \
			Name='2 Tier VPC - created by Pras for learning' \
			# pras:version=$(VERSION) \
			# pras:githash=$(COMMIT_HASH)
.PHONY: deploy-vpc

deploy-docker-asgs: ## Deploy customer network factory - custom network step function
# ifndef GIT_BRANCH
# 	$(error GIT_BRANCH is undefined, define in parent shell)
# endif
	@aws cloudformation deploy \
		--s3-bucket $(CFN_ARTIFACT_BUCKET_NAME) \
	    --template-file cfn/deploy-asgs.yml \
		--stack-name pras-learning-asg \
		--capabilities CAPABILITY_NAMED_IAM \
		--no-fail-on-empty-changeset \
		--parameter-overrides \
			NewRelicLicenceKey=$(NEW_RELIC_LICENCE_KEY) \
			SnsStackName=$(SNS_STACK_NAME) \
		--tags \
			Name='Created by Pras for learning'
.PHONY: deploy-docker-asgs
