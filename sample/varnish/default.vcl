vcl 4.1;
import dynamic;

# Configuration des backends
backend default {
    .host = "web";
    .port = "80";
}

backend sell {
    .host = "sell";
    .port = "80";
}

sub vcl_init {
    #new d = dynamic.director(port = "80");
}

sub vcl_recv {

    set req.backend_hint = default;
    # On pass le cache
    if (req.method != "GET" && req.method != "HEAD") {
        return (pass);
    }

    # Multifront
    if(req.url ~ "^/prices") {
        set req.backend_hint = sell;
    }

    # Configuration des statics
    if (req.url ~ "^[^?]*\.(7z|avi|bmp|bz2|css|csv|doc|docx|eot|flac|flv|gif|gz|ico|jpeg|jpg|js|less|mka|mkv|mov|mp3|mp4|mpeg|mpg|odt|ogg|ogm|opus|otf|pdf|png|ppt|pptx|rar|rtf|svg|svgz|swf|tar|tbz|tgz|ttf|txt|txz|wav|webm|webp|woff|woff2|xls|xlsx|xml|xz|zip)(\?.*)?$") {
        unset req.http.Cookie;
        unset req.http.Authorization;
        return(hash);
    }
    # Configuration du contenu html
    if (req.url ~ "^[^?]*\.(html)(\?.*)?$") {
        unset req.http.Cookie;
        unset req.http.Authorization;
        return(hash);
    }
}

# Activation des ESI
sub vcl_backend_response {
    set beresp.do_esi = true;
}

# Add debug header
sub vcl_deliver {
    if (obj.hits > 0) {
        set resp.http.X-Cache = "HIT";
    } else {
        set resp.http.X-Cache = "MISS";
    }
    set resp.http.X-Cache-Hits = obj.hits;
    return (deliver);
}
