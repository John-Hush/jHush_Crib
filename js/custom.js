$( document ).ready(function() {

  $(".view-slide > .view-content").slick({
    arrows: false,
    adaptiveHeight: true,
    autoplay: true,
    autoplaySpeed: 3000,
  });

  $('[data-toggle="offcanvas"]').click(function () {
      $('.sidebar-offcanvas').toggleClass('active');
    });

});
