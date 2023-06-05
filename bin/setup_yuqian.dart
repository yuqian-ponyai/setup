import 'package:setup/dotfile.dart';
import 'package:setup/setup.dart';
import 'package:setup/zsh.dart';

Future<void> main() async {
  await setVimInBashrc.apply();
  await installGit.apply();
  await gitConfig.apply();

  await installTmux.apply();
  await ohMyTmux.apply();
  await installXclip.apply();

  await setUpZsh(kDotfileRootUrl);

  await addNodejs19.apply();
  await installNodejs.apply();

  await ultimateVimrc.apply();
  await dartVimPlugin.apply();
  await fzfVimPlugin.apply();
  await cocVimPlugin.apply();

  await downloadDotfiles(kDotfileRootUrl);
}

const String kDotfileRootUrl =
    'https://raw.githubusercontent.com/liyuqian/setup/main/dotfiles';

final installGit = AptInstall('git');
final installTmux = AptInstall('tmux');
final installXclip = AptInstall('xclip');

final addNodejs19 = SetupByCmds(
  'add nodejs 19',
  commands: [
    Cmd('curl -fsSL https://deb.nodesource.com/setup_19.x -o /tmp/node.sh'),
    Cmd('sudo -E bash /tmp/node.sh'),
  ],
  check: CheckByCmd(
    Cmd('apt list nodejs'),
    (stdout) => stdout.contains(' 19'),
  ),
);
final installNodejs = AptInstall('nodejs');

final setVimInBashrc = ConfigFileSetup(
  'bashrc editor',
  filepath: '$home/.bashrc',
  lines: [
    'export VISUAL=vim',
    'export EDITOR="\$VISUAL"',
  ],
);

final gitConfig = SetupByCmds(
  'config git',
  commands: [
    Cmd.args(['git', 'config', '--global', 'user.name', 'Yuqian Li']),
    Cmd('git config --global user.email "liyuqian79@gmail.com"'),
  ],
  check: CheckByCmd(
    Cmd('git config --global user.name'),
    (stdout) => stdout.contains('Yuqian Li'),
  ),
);

final ohMyTmux = SetupByCmds('install oh-my-tmux',
    commands: Cmd.simpleLines([
      'git clone https://github.com/gpakosz/.tmux.git',
      'ln -s -f .tmux/.tmux.conf',
      'cp .tmux/.tmux.conf.local .',
    ], path: home),
    check: FileCheck('$home/.tmux.conf'));

final ultimateVimrc = SetupByCmds(
  'ultimate vimrc',
  commands: [
    Cmd.args([
      'git',
      'clone',
      '--depth=1',
      'https://github.com/amix/vimrc.git',
      '$home/.vim_runtime',
    ]),
    Cmd('sh $home/.vim_runtime/install_awesome_vimrc.sh'),
  ],
  check: CheckByCmd(
    Cmd('cat $home/.vimrc'),
    (stdout) => stdout.contains('.vim_runtime'),
    okExitCodes: [0, 1],
  ),
);

class VimPlugin extends SetupByCmds {
  VimPlugin(String url, {String? branch})
      : super(
          parseName(url),
          commands: [
            Cmd.args(
              ['git', 'clone', '--depth=1'] +
                  (branch != null ? ['-b', branch] : []) +
                  [url, '$path/${parseName(url)}'],
            ),
          ],
          check: FileCheck('$path/${parseName(url)}'),
        );

  static String get path => '$home/.vim_runtime/my_plugins';
  static String parseName(String url) => Uri.parse(url).pathSegments.last;
}

// final getDartVimPlugin = SetupByCmds(
//   'dart vim plugin',
//   commands: [
//     Cmd.args([
//       'git',
//       'clone',
//       'https://github.com/dart-lang/dart-vim-plugin',
//       '$home/.vim_runtime/my_plugins/dart-vim-plugin'
//     ]),
//   ],
//   check: FileCheck('$home/.vim_runtime/my_plugins/dart-vim-plugin/README.md'),
// );

final dartVimPlugin = VimPlugin('https://github.com/dart-lang/dart-vim-plugin');
final fzfVimPlugin = VimPlugin('https://github.com/junegunn/fzf.vim');
final cocVimPlugin =
    VimPlugin('https://github.com/neoclide/coc.nvim', branch: 'release');
