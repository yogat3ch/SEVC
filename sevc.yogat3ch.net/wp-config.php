<?php
/**
 * The base configuration for WordPress
 *
 * The wp-config.php creation script uses this file during the
 * installation. You don't have to use the web site, you can
 * copy this file to "wp-config.php" and fill in the values.
 *
 * This file contains the following configurations:
 *
 * * MySQL settings
 * * Secret keys
 * * Database table prefix
 * * ABSPATH
 *
 * @link https://codex.wordpress.org/Editing_wp-config.php
 *
 * @package WordPress
 */

// ** MySQL settings ** //
/** The name of the database for WordPress */
define( 'DB_NAME', 'dhammapatapa_2017_03_13' );

/** MySQL database username */
define( 'DB_USER', 'dhammapatapa_wp' );

/** MySQL database password */
define( 'DB_PASSWORD', '6Le9INAv3sSg' );

/** MySQL hostname */
define( 'DB_HOST', 'localhost' );

/** Database Charset to use in creating database tables. */
define( 'DB_CHARSET', 'utf8' );

/** The Database Collate type. Don't change this if in doubt. */
define( 'DB_COLLATE', '' );

/**
 * Authentication Unique Keys and Salts.
 *
 * Change these to different unique phrases!
 * You can generate these using the {@link https://api.wordpress.org/secret-key/1.1/salt/ WordPress.org secret-key service}
 * You can change these at any point in time to invalidate all existing cookies. This will force all users to have to log in again.
 *
 * @since 2.6.0
 */
define('AUTH_KEY',         'jljh:)lH|mt>St~d*6,WU47w+i1~CDowJ/v*,*fPK*3U-#G-P?M=9TIf0)!+T>+ ');
define('SECURE_AUTH_KEY',  '-DUIl@G^)F2dA]-QVZL-?v}Cm `OEhQBs@|YCOUor~R~:m%tAD2-hc4ja#>Y@O%6');
define('LOGGED_IN_KEY',    '#1>AK5zNcSO+%P|fC=F:0d>>ky>N:?*0d{cCm$lVPKX)VsygB(C[j^Y%yie/mn&p');
define('NONCE_KEY',        'd)?KO#KS3|#G *opvhfL`EZZBv=-lpE($9J<S-n{ru8M}aX+y,XBV:J7+85uoP3D');
define('AUTH_SALT',        'fX+6E-`NJ|^5zX<:jV;py#f6zIM~8Wp|||l O[4zc4#(pbrRd~^D Ni4/C%6R`Ze');
define('SECURE_AUTH_SALT', 'tUHj9DMV0q*SQw5a!qhEDt&+xJOX^J%Ghd$U.y|@rrIN!-R;rMHw6%nON2)3q=!(');
define('LOGGED_IN_SALT',   'x7iz?Pz*l>rcfvOrZH).F|TRZjW/|j0V.477_a.IhLI.N@q_4YzeSOD;}W=x&jTe');
define('NONCE_SALT',       '!y*w`2|>a;D*}#}:<t=Sz[,3W#%!NS*bL8/)#bNk3#MP{0GEjcYDGh*P+e*B6#`n');


/**
 * WordPress Database Table prefix.
 *
 * You can have multiple installations in one database if you give each
 * a unique prefix. Only numbers, letters, and underscores please!
 */
$table_prefix = 'wp_';




/* That's all, stop editing! Happy blogging. */

/** Absolute path to the WordPress directory. */
if ( ! defined( 'ABSPATH' ) )
	define( 'ABSPATH', dirname( __FILE__ ) . '/' );

/** Sets up WordPress vars and included files. */
require_once ABSPATH . 'wp-settings.php';
