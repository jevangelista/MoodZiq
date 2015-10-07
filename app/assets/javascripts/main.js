$(document).ready(function() {
   //sanity check
   console.log("Don't Panic!");

   $("#drop-btn").on("click", function() {
      $("#profile-wrapper").slideToggle();
   });

});
