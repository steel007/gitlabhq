class Spinach::Features::ProjectMergeRequests < Spinach::FeatureSteps
  include SharedAuthentication
  include SharedIssuable
  include SharedProject
  include SharedNote
  include SharedPaths
  include SharedMarkdown
  include SharedDiffNote

  step 'I click link "New Merge Request"' do
    click_link "New Merge Request"
  end

  step 'I click link "Bug NS-04"' do
    click_link "Bug NS-04"
  end

  step 'I click link "All"' do
    click_link "All"
  end

  step 'I click link "Closed"' do
    click_link "Closed"
  end

  step 'I should see merge request "Wiki Feature"' do
    within '.merge-request' do
      page.should have_content "Wiki Feature"
    end
  end

  step 'I should see closed merge request "Bug NS-04"' do
    merge_request = MergeRequest.find_by!(title: "Bug NS-04")
    merge_request.closed?.should be_true
    page.should have_content "Closed by"
  end

  step 'I should see merge request "Bug NS-04"' do
    page.should have_content "Bug NS-04"
  end

  step 'I should see "Bug NS-04" in merge requests' do
    page.should have_content "Bug NS-04"
  end

  step 'I should see "Feature NS-03" in merge requests' do
    page.should have_content "Feature NS-03"
  end

  step 'I should not see "Feature NS-03" in merge requests' do
    page.should_not have_content "Feature NS-03"
  end


  step 'I should not see "Bug NS-04" in merge requests' do
    page.should_not have_content "Bug NS-04"
  end

  step 'I click link "Close"' do
    first(:css, '.close-mr-link').click
  end

  step 'I submit new merge request "Wiki Feature"' do
    select "fix", from: "merge_request_source_branch"
    select "feature", from: "merge_request_target_branch"
    click_button "Compare branches"
    fill_in "merge_request_title", with: "Wiki Feature"
    click_button "Submit merge request"
  end

  step 'project "Shop" have "Bug NS-04" open merge request' do
    create(:merge_request,
           title: "Bug NS-04",
           source_project: project,
           target_project: project,
           source_branch: 'fix',
           target_branch: 'master',
           author: project.users.first,
           description: "# Description header"
          )
  end

  step 'project "Shop" have "Bug NS-05" open merge request with diffs inside' do
    create(:merge_request_with_diffs,
           title: "Bug NS-05",
           source_project: project,
           target_project: project,
           author: project.users.first)
  end

  step 'project "Shop" have "Feature NS-03" closed merge request' do
    create(:closed_merge_request,
           title: "Feature NS-03",
           source_project: project,
           target_project: project,
           author: project.users.first)
  end

  step 'project "Shop" has "MR-task-open" open MR with task markdown' do
    create_taskable(:merge_request, 'MR-task-open')
  end

  step 'I switch to the diff tab' do
    visit diffs_project_merge_request_path(project, merge_request)
  end

  step 'I switch to the merge request\'s comments tab' do
    visit project_merge_request_path(project, merge_request)
  end

  step 'I click on the commit in the merge request' do
    within '.merge-request-tabs' do
      click_link 'Commits'
    end

    within '.mr-commits' do
      click_link Commit.truncate_sha(sample_commit.id)
    end
  end

  step 'I leave a comment on the diff page' do
    init_diff_note
    leave_comment "One comment to rule them all"
  end

  step 'I leave a comment on the diff page in commit' do
    click_diff_line(sample_commit.line_code)
    leave_comment "One comment to rule them all"
  end

  step 'I leave a comment like "Line is wrong" on diff' do
    init_diff_note
    leave_comment "Line is wrong"
  end

  step 'I leave a comment like "Line is wrong" on diff in commit' do
    click_diff_line(sample_commit.line_code)
    leave_comment "Line is wrong"
  end

  step 'I should see a discussion has started on diff' do
    page.should have_content "#{current_user.name} started a discussion"
    page.should have_content sample_commit.line_code_path
    page.should have_content "Line is wrong"
  end

  step 'I should see a discussion has started on commit diff' do
    page.should have_content "#{current_user.name} started a discussion on commit"
    page.should have_content sample_commit.line_code_path
    page.should have_content "Line is wrong"
  end

  step 'I should see a discussion has started on commit' do
    page.should have_content "#{current_user.name} started a discussion on commit"
    page.should have_content "One comment to rule them all"
  end

  step 'merge request is mergeable' do
    page.should have_content 'You can accept this request automatically'
  end

  step 'I modify merge commit message' do
    find('.modify-merge-commit-link').click
    fill_in 'commit_message', with: 'wow such merge'
  end

  step 'merge request "Bug NS-05" is mergeable' do
    merge_request.mark_as_mergeable
  end

  step 'I accept this merge request' do
    Gitlab::Satellite::MergeAction.any_instance.stub(
      merge!: true,
    )

    click_button "Accept Merge Request"
  end

  step 'I should see merged request' do
    within '.issue-box' do
      page.should have_content "Merged"
    end
  end

  step 'I click link "Reopen"' do
    first(:css, '.reopen-mr-link').click
  end

  step 'I should see reopened merge request "Bug NS-04"' do
    within '.issue-box' do
      page.should have_content "Open"
    end
  end

  step 'I click link "Hide inline discussion" of the second file' do
    within '.files [id^=diff]:nth-child(2)' do
      click_link "Diff comments"
    end
  end

  step 'I click link "Show inline discussion" of the second file' do
    within '.files [id^=diff]:nth-child(2)' do
      click_link "Diff comments"
    end
  end

  step 'I should not see a comment like "Line is wrong" in the second file' do
    within '.files [id^=diff]:nth-child(2)' do
      page.should_not have_visible_content "Line is wrong"
    end
  end

  step 'I should see a comment like "Line is wrong" in the second file' do
    within '.files [id^=diff]:nth-child(2) .note-text' do
      page.should have_visible_content "Line is wrong"
    end
  end

  step 'I should not see a comment like "Line is wrong here" in the second file' do
    within '.files [id^=diff]:nth-child(2)' do
      page.should_not have_visible_content "Line is wrong here"
    end
  end

  step 'I should see a comment like "Line is wrong here" in the second file' do
    within '.files [id^=diff]:nth-child(2) .note-text' do
      page.should have_visible_content "Line is wrong here"
    end
  end

  step 'I leave a comment like "Line is correct" on line 12 of the first file' do
    init_diff_note_first_file

    within(".js-discussion-note-form") do
      fill_in "note_note", with: "Line is correct"
      click_button "Add Comment"
    end

    within ".files [id^=diff]:nth-child(1) .note-text" do
      page.should have_content "Line is correct"
    end
  end

  step 'I leave a comment like "Line is wrong" on line 39 of the second file' do
    init_diff_note_second_file

    within(".js-discussion-note-form") do
      fill_in "note_note", with: "Line is wrong on here"
      click_button "Add Comment"
    end
  end

  step 'I should still see a comment like "Line is correct" in the first file' do
    within '.files [id^=diff]:nth-child(1) .note-text' do
      page.should have_visible_content "Line is correct"
    end
  end

  step 'I unfold diff' do
    first('.js-unfold').click
  end

  step 'I should see additional file lines' do
    expect(first('.text-file')).to have_content('.bundle')
  end

  step 'I click Side-by-side Diff tab' do
    click_link 'Side-by-side'
  end

  step 'I should see comments on the side-by-side diff page' do
    within '.files [id^=diff]:nth-child(1) .note-text' do
      page.should have_visible_content "Line is correct"
    end
  end

  def merge_request
    @merge_request ||= MergeRequest.find_by!(title: "Bug NS-05")
  end

  def init_diff_note
    click_diff_line(sample_commit.line_code)
  end

  def leave_comment(message)
    within(".js-discussion-note-form") do
      fill_in "note_note", with: message
      click_button "Add Comment"
    end

    page.should have_content message
  end

  def init_diff_note_first_file
    click_diff_line(sample_compare.changes[0][:line_code])
  end

  def init_diff_note_second_file
    click_diff_line(sample_compare.changes[1][:line_code])
  end

  def have_visible_content (text)
    have_css("*", text: text, visible: true)
  end
end
