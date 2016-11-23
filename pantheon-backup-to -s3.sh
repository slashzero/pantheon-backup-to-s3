#!/bin/sh

# pantheon-backup-to-s3.sh
# Script to backup Pantheon sites and copy to Amazon s3 bucket
#
# Requirements:
#   - Pantheon terminus cli
#   - Valid terminus machine token
#   - Amazon aws cli
#   - s3 cli access and user configured


# The amazon S3 bucket to save the backups to (must already exist)
S3BUCKET=""
# The Pantheon terminus user 
TERMINUSUSER=""
# Site names to backup (e.g. 'site-one site-two')
SITENAMES=""
# Site environments to backup (any combination of dev, test and live)
SITEENVS=""
# Site elements to backup (any combination of files, database and code)
SITEELEMENTS=""
# Local backup directory (must exist, requires trailing slash)
BACKUPDIR=""

# connect to terminus
terminus auth login $TERMINUS_USER

# iterate through sites to backup
for thissite in $SITENAMES; do

	# iterate through current site environments
	for thisenv in $SITEENVS; do

		# iterate through current site elements
		for thiselement in $SITEELEMENTS; do
			terminus site backups create --site=$thissite --env=$thisenv --element=$thiselement
		done
		
		# download current site backups
		terminus site backups get --latest --site=$thissite --env=$thisenv --element=$thiselement --to=$BACKUPDIR
	done
done

# sync the local backup directory to aws s3
aws s3 sync $BACKUPDIR s3://$S3BUCKET




