import Rails from "@rails/ujs";
import Turbolinks from "turbolinks";
import * as ActiveStorage from "@rails/activestorage";
import "channels";
import "jsvectormap/dist/css/jsvectormap.css";
import "flatpickr/dist/flatpickr.min.css";
import "./main";
import "./swiper-bundle.min.js";
window.WOW = require('wowjs').WOW;

Rails.start();
Turbolinks.start();
ActiveStorage.start();

document.addEventListener('DOMContentLoaded', () => {
  const userDropdownToggle = document.getElementById('user-dropdown-toggle');
  const userDropdownMenu = document.getElementById('user-dropdown-menu');

  if (userDropdownToggle && userDropdownMenu) {
    userDropdownToggle.addEventListener('click', (e) => {
      e.preventDefault();
      userDropdownMenu.classList.toggle('hidden');
    });

    // Close the dropdown if clicked outside
    document.addEventListener('click', (event) => {
      if (!userDropdownToggle.contains(event.target) && !userDropdownMenu.contains(event.target)) {
        userDropdownMenu.classList.add('hidden');
      }
    });
  }

  // Initialize WOW.js
  new WOW().init();
});
