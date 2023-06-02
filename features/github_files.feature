Feature: Files from github

  As a developer
  I want to be able to fetch a file from Github
  Because that is where my content is stored


  Scenario: Fetching a single file from the root of the repository
    Given a file in Github located at "/README.md"
    And a model extending GitRecord::Remote
    When I find the file "README.md"
    Then I get back that file

  Scenario: Fetching a single file from a sub-directory of the repository
    Given a file in Github located at "foo/bar.md"
    And a model backed by Github
    When I find the file "foo/bar.md"
    Then I get back that file

  Scenario: Fetching a single markdown file of the respository
    Given a file in Github located at "foo/bar.md"
    With the contents:
      "# Hello world"
    And a model extending GitRecord::Remote
    When I find the file "foo/bar.md"
    Then I get back that file
    And its body is:
      "<h1>Hello world</h1>"