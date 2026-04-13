<?php
// +-----------------------------------------------------------------------+
// | This file is part of Mozaic plugin for Piwigo.                        |
// |                                                                       |
// | For copyright and license information, please view the COPYING.md     |
// | file that was distributed with this source code.                      |
// +-----------------------------------------------------------------------+

// Recursive call
$url = '../';
header( 'Request-URI: '.$url );
header( 'Content-Location: '.$url );
header( 'Location: '.$url );
exit();
?>
