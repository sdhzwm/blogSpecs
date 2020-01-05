{% if theme.valine.appid and theme.valine.appkey %}
<!-- valine Comments -->
<!-- do not set the version number -->
<script src="//unpkg.com/valine/dist/Valine.min.js"></script>
<!-- or set latest -->
<script src="//unpkg.com/valine@latest/dist/Valine.min.js"></script>
<!-- or Default value -->
<script src="//unpkg.com/valine"></script>
<script type="text/javascript">
    new Valine({
        el: '#vcomments',
        notify: {{ theme.valine.notify }},
        verify: {{ theme.valine.verify }},
        app_id: "{{ theme.valine.appid }}",
        app_key: "{{ theme.valine.appkey }}",
        placeholder: "{{ theme.valine.placeholder }}",
        avatar: '{{ theme.valine.avatar }}'
    });
</script>
{% endif %}

