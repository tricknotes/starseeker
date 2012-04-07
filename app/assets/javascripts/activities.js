function showRepoDetails() {
  var $repo = $(this)
    , repo_name = $repo.data('repo_name')

  $.ajax(
      'https://api.github.com/repos/'+repo_name
    , {
        dataType: 'jsonp'
      , success: function(repo) {
          var $description = $repo.find('.description')
            , $wathers = $repo.find('.watchers')

          $description.text(repo.data.description);
          $wathers.text('['+repo.data.watchers+']');
      }
    }
  );
}
