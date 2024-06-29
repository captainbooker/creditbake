//= require turbolinks
//= require active_admin/base
//= require activeadmin/froala_editor/froala_editor.pkgd.min
//= require activeadmin/froala_editor_input

document.addEventListener('turbolinks:load', function() {
  console.log("big boy")
  new FroalaEditor('textarea.froala-editor', {
    imageUploadURL: '/admin/uploads',
    imageUploadParams: {
      id: 'my_editor'
    }
  });
});
  