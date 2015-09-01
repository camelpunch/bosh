# Steps for High-Priority, "Hotfix" Releases

## If there are no code changes

(only kernel and/or package updates)...

- [ ] Create a `hotfix-STORY_ID` branch off of `master`
- [ ] Push the hotfix branch
- [ ] Kick off OS Image build(s) with `hotfix-STORY_ID` as the
  value for `BUILD_FLOW_GIT_COMMIT`
- [ ] Update:
  - `bosh-stemcell/OS_IMAGES.md`
  - `bosh-dev/.../os_image_versions.json`

  ...with the published OS image s3 key, found at the end of the
  OS image build output; push that change
- [ ] Kick off the full Jenkins pipeline, based on the hotfix branch and
  setting `FEATURE_BRANCH` as `hotfix-STORY_ID`
- [ ] Upon successful completion of the Jenkins pipeline, locally...
  - [ ] `git pull hotfix-STORY_ID`
  - [ ] `git pull develop`
  - [ ] `git merge hotfix-STORY_ID` (onto `develop`)
- [ ] Update the `promote_artifacts` step to switch back to `develop`

## If there are code changes

(to bosh or bosh-agent)...

- [ ] Create a `hotfix-STORY_ID` branch off of `master`
- [ ] Make code changes and push the hotfix branch
- [ ] Copy `ci/pipeline.yml` to `ci/pipeline-hotfix-STORY_ID.yml` and
  configure a new `hotfix-STORY_ID` pipeline; push this change

  **NOTE:** this pipeline should...
  - [ ] Reference the hotfix branch
  - [ ] **Exclude** the `promote-candidate` and `publish-coverage` steps
- [ ] Follow steps 3-8 above (if there are no OS changes, you can probably
  skip steps 3 & 4 from above)

## Caveats:

- If your vars-from contents (secrets) are out of sync between `master` and
  `develop` at the start of all of this, well... hmm...