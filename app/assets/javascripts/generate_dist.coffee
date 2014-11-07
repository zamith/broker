$ ->
  $(document).on 'click', '.js-ask-for-branch', (event) ->
    event.preventDefault()
    $el = $(event.currentTarget)

    branchName = prompt("Enter the name of the branch to build from", "develop")
    if branchName?
      $.post $el.attr("href"), { branch_name: branchName }, (data) ->
        $("#flash").html("<div id='flash_notice'>Generating dist for branch #{branchName}</div>")
        setTimeout ->
            $("#flash_notice").fadeOut("slow")
            $("#flash").html()
        , 3000
    else
      alert("The branch name can't be empty. Please try again.")


