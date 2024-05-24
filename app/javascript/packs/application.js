// app/javascript/packs/application.js

import Rails from "@rails/ujs";
import Turbolinks from "turbolinks";
import * as ActiveStorage from "@rails/activestorage";
import "channels";
import "jsvectormap/dist/css/jsvectormap.css";
import "flatpickr/dist/flatpickr.min.css";

Rails.start();
Turbolinks.start();
ActiveStorage.start();


document.addEventListener('DOMContentLoaded', () => {
  const userDropdownToggle = document.getElementById('user-dropdown-toggle');
  const userDropdownMenu = document.getElementById('user-dropdown-menu');

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
});
