import ExtensionAbility from '@ohos.app.ability.ExtensionAbility';
import hilog from '@ohos.hilog';
import type AbilityConstant from '@ohos.app.ability.AbilityConstant';
import type Want from '@ohos.app.ability.Want';

export default class EntryBackupAbility extends ExtensionAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'BlogApp', '%{public}s', 'EntryBackupAbility onCreate');
  }

  onDestroy(): void {
    hilog.info(0x0000, 'BlogApp', '%{public}s', 'EntryBackupAbility onDestroy');
  }
}
