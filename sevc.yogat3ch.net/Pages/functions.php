<?php
add_action( 'wp_enqueue_scripts', 'my_theme_enqueue_styles' );
function my_theme_enqueue_styles() {
    wp_enqueue_style( 'parent-style', get_template_directory_uri() . '/style.css' );
 
}
function wp_body_classes( $id )
{
    $id[] = '" id='sr' "';

    return $id;
}
add_filter( 'body_class','wp_body_classes', 999 );

?>