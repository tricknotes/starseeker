function showRepoDescription() {
  var $repo_description = $(this);
  var repo_name = $repo_description.data('repo_name');

  $.ajax(
      'https://api.github.com/repos/'+repo_name
    , {
        dataType: 'jsonp'
      , success: function(repo) {
          $repo_description.html(repo.data.description);
      }
    }
  );
}
