use strict;
use warnings;
use opts 0.05;
use autodie;
use Plack::Request;
use File::Path qw(mkpath);
use File::chdir;
use Sys::Hostname;
use Text::MicroTemplate qw(render_mt);

sub git (@);
sub whole (&);

my %defaults = (
    hostname    => hostname(),
    git_root    => 'db',
    pull_remote => [ 'origin' ],
    push_remote => 'origin',
    log_format  => '<%an> %s %ar',
);

my %config = ( %defaults, do 'config.pl' );

my $hostname    = $config{hostname};
my $git_root    = $config{git_root};
my $pull_remote = $config{pull_remote};
my $push_remote = $config{push_remote};
   $pull_remote = [ $pull_remote ] if ref $pull_remote ne 'ARRAY';
my $log_format  = $config{log_format};

mkpath $git_root;
git 'init';

my $Template = whole { <DATA> };

my $app = sub {
    my $env = shift;
    my $req = Plack::Request->new($env);

    if ($req->path_info eq '/pull') {
        foreach (@$pull_remote) {
            git pull => $_, 'master';
        }
        return [ 302, [ Location => '/' ], [] ];
    }

    if ($req->path_info eq '/push') {
        git push => $push_remote, 'master';
        return [ 302, [ Location => '/' ], [] ];
    }

    if ($req->method eq 'POST') {
        my $message = $req->param('message') || '';
        my $name    = $req->param('name') || '';
        if (length $message) {
            git commit => '--allow-empty', '--message' => $message, length $name ? ( '--author' => "$name <$name\@$hostname>" ) : ();
            git push => $push_remote, 'master';
        } else {
            foreach (@$pull_remote) {
                git pull => $_, 'master';
            }
        }
        return [ 302, [ Location => '/' ], [] ];
    } else {
        my $html = render_mt($Template, log => whole { git log => "--pretty=format:$log_format", '--no-merges' });
        return [ 200, [ 'Content-Type' => 'text/html; charset=utf-8' ], [ $html ] ];
    }
};

sub git (@) {
    local $CWD = $git_root;
    #open my $pipe, '-|', (git => @_);
    open (my $pipe, '-|') || exec (git => @_);
    return <$pipe>;
}

sub whole (&) {
    my $block = shift;
    local $/;
    return scalar $block->();
}

__DATA__
? local %_ = @_;
<!DOCTYPE html>
<html>
<head>
  <title>Git Log Relay Chat</title>
  <meta charset="utf-8" />
</head>
<body>
  <form action="/" method="post">
    <input type="text" name="message" placeholder="message" id="text">
    <input type="submit" value="enter">
  </form>
  <pre><?= $_{log} ?></pre>
  <script type="text/javascript">
  document.getElementById('text').focus();
  </script>
</body>
</html>
