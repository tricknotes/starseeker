function showRepoDetails() {
  var $repo = $(this);
  var repo_name = $repo.data('repo_name');

  $.ajax(
      'https://api.github.com/repos/'+repo_name
    , {
        dataType: 'jsonp'
      , success: function(repo) {
          var $description = $repo.find('.description');
          $description.html(repo.data.description);
      }
    }
  );
}
