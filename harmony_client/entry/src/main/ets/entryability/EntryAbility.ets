import hilog from '@ohos.hilog';
import UIAbility from '@ohos.app.ability.UIAbility';
import type AbilityConstant from '@ohos.app.ability.AbilityConstant';
import type Want from '@ohos.app.ability.Want';
import type window from '@ohos.window';

/**
 * 应用入口
 */
export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    hilog.info(0x0000, 'BlogApp', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(0x0000, 'BlogApp', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(0x0000, 'BlogApp', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Login', (err, data) => {
      if (err.code) {
        hilog.error(0x0000, 'BlogApp', 'Failed to load content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      hilog.info(0x0000, 'BlogApp', 'Succeeded in loading content. Data: %{public}s', JSON.stringify(data) ?? '');
    });
  }

  onWindowStageDestroy(): void {
    hilog.info(0x0000, 'BlogApp', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    hilog.info(0x0000, 'BlogApp', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    hilog.info(0x0000, 'BlogApp', '%{public}s', 'Ability onBackground');
  }
}
