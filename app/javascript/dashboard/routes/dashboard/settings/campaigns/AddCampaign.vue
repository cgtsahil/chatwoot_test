<template>
  <div class="column content-box">
    <woot-modal-header
      :header-title="$t('CAMPAIGN.ADD.TITLE')"
      :header-content="$t('CAMPAIGN.ADD.DESC')"
    />
    <form class="row" @submit.prevent="addCampaign">
      <div class="medium-12 columns">
        <label :class="{ error: $v.selectedInbox.$error }">
          {{ $t('CAMPAIGN.ADD.FORM.INBOX.LABEL') }}
          <select v-model="selectedInbox" @change="onChangeInbox($event)">
            <option v-for="item in inboxes" :key="item.name" :value="item.id">
              {{ item.name }}
            </option>
          </select>
          <span v-if="$v.selectedInbox.$error" class="message">
            {{ $t('CAMPAIGN.ADD.FORM.INBOX.ERROR') }}
          </span>
        </label>
        <woot-input
          v-model="title"
          :label="$t('CAMPAIGN.ADD.FORM.TITLE.LABEL')"
          type="text"
          :class="{ error: $v.title.$error }"
          :error="$v.title.$error ? $t('CAMPAIGN.ADD.FORM.TITLE.ERROR') : ''"
          :placeholder="$t('CAMPAIGN.ADD.FORM.TITLE.PLACEHOLDER')"
          @blur="$v.title.$touch"
        />

        <label v-if="mailEnabled" :class="{ error: $v.message.$error }">
          {{ $t('CAMPAIGN.ADD.FORM.SUBJECT.LABEL') }}
          <textarea
            v-model="subject"
            rows="2"
            type="text"
            :placeholder="$t('CAMPAIGN.ADD.FORM.SUBJECT.PLACEHOLDER')"
          />
          <span v-if="$v.message.$error" class="message">
            {{ $t('CAMPAIGN.ADD.FORM.SUBJECT.ERROR') }}
          </span>
        </label>

        <label v-if="isOngoingType" class="editor-wrap">
          {{ $t('CAMPAIGN.ADD.FORM.MESSAGE.LABEL') }}
          <woot-message-editor
            v-model="message"
            class="message-editor"
            :class="{ editor_warning: $v.message.$error }"
            :placeholder="$t('CAMPAIGN.ADD.FORM.MESSAGE.PLACEHOLDER')"
            @blur="$v.message.$touch"
          />
          <span v-if="$v.message.$error" class="editor-warning__message">
            {{ $t('CAMPAIGN.ADD.FORM.MESSAGE.ERROR') }}
          </span>
        </label>

        <label v-else :class="{ error: $v.message.$error }">
          {{ $t('CAMPAIGN.ADD.FORM.MESSAGE.LABEL') }}
          <textarea
            v-model="message"
            rows="5"
            type="text"
            :placeholder="$t('CAMPAIGN.ADD.FORM.MESSAGE.PLACEHOLDER')"
            @blur="$v.message.$touch"
          />
          <span v-if="$v.message.$error" class="message">
            {{ $t('CAMPAIGN.ADD.FORM.MESSAGE.ERROR') }}
          </span>
        </label>

        <label
          v-if="isOnOffType && !this.mailEnabled"
          :class="{ error: $v.selectedAudience.$error }"
        >
          {{ $t('CAMPAIGN.ADD.FORM.AUDIENCE.LABEL') }}
          <multiselect
            v-model="selectedAudience"
            :options="audienceList"
            track-by="id"
            label="title"
            :multiple="true"
            :close-on-select="false"
            :clear-on-select="false"
            :hide-selected="true"
            :placeholder="$t('CAMPAIGN.ADD.FORM.AUDIENCE.PLACEHOLDER')"
            selected-label
            :select-label="$t('FORMS.MULTISELECT.ENTER_TO_SELECT')"
            :deselect-label="$t('FORMS.MULTISELECT.ENTER_TO_REMOVE')"
            @blur="$v.selectedAudience.$touch"
            @select="$v.selectedAudience.$touch"
          />
          <span v-if="$v.selectedAudience.$error" class="message">
            {{ $t('CAMPAIGN.ADD.FORM.AUDIENCE.ERROR') }}
          </span>
        </label>

        <label
          v-if="isOnOffType && mailEnabled"
          :class="{ error: $v.selectedAction.$error }"
        >
          {{ $t('CAMPAIGN.ADD.FORM.PERFORM_ACTION.LABEL') }}
          <select v-model="selectedAction">
            <option
              v-for="item in mailAction"
              :key="item.name"
              :value="item.id"
            >
              {{ item.name }}
            </option>
          </select>
          <span v-if="$v.selectedAction.$error" class="message">
            {{ $t('CAMPAIGN.ADD.FORM.PERFORM_ACTION.ERROR') }}
          </span>
        </label>

        <label
          v-if="
            isOnOffType &&
              mailEnabled &&
              (selectedAction === 2 || selectedAction === 3)
          "
          :class="{ error: $v.selectedMail.$error }"
        >
          {{ $t('CAMPAIGN.ADD.FORM.REPLY_MAIL.LABEL') }}
          <select v-model="selectedMail" @change="actionChange">
            <option
              v-for="item in mailCampaigns"
              :key="item.title"
              :value="item.id"
            >
              {{ item.title }}
            </option>
          </select>
          <span v-if="$v.selectedMail.$error" class="message">
            {{ $t('CAMPAIGN.ADD.FORM.REPLY_MAIL.ERROR') }}
          </span>
        </label>

        <label
          v-if="
            isOnOffType &&
              mailEnabled &&
              selectedMail &&
              (selectedAction === 2 || selectedAction === 3)
          "
          :class="{ error: $v.selectedPreference.$error }"
        >
          {{ $t('CAMPAIGN.ADD.FORM.REPLY_PREFERENCE.LABEL') }}
          <select v-model="selectedPreference">
            <option
              v-for="item in mailPreferences.filter(
                property => !this.presentPreferences.includes(property.id)
              )"
              :key="item.name"
              :value="item.id"
            >
              {{ item.name }}
            </option>
          </select>
          <span v-if="$v.selectedPreference.$error" class="message">
            {{ $t('CAMPAIGN.ADD.FORM.REPLY_PREFERENCE.ERROR') }}
          </span>
        </label>

        <label
          v-if="
            isOnOffType &&
              mailEnabled &&
              selectedMail &&
              (selectedAction === 2 || selectedAction === 3)
          "
          :class="{ error: $v.selectedTime.$error }"
        >
          {{ $t('CAMPAIGN.ADD.FORM.SCHEDULED_TIME.LABEL') }}
          <select v-model="selectedTime">
            <option
              v-for="item in mailTime"
              :key="item.name"
              :value="item.value"
            >
              {{ item.name }}
            </option>
          </select>
          <span v-if="$v.selectedTime.$error" class="message">
            {{ $t('CAMPAIGN.ADD.FORM.SCHEDULED_TIME.ERROR') }}
          </span>
        </label>

        <label
          v-if="isOngoingType"
          :class="{ error: $v.selectedSender.$error }"
        >
          {{ $t('CAMPAIGN.ADD.FORM.SENT_BY.LABEL') }}
          <select v-model="selectedSender">
            <option
              v-for="sender in sendersAndBotList"
              :key="sender.name"
              :value="sender.id"
            >
              {{ sender.name }}
            </option>
          </select>
          <span v-if="$v.selectedSender.$error" class="message">
            {{ $t('CAMPAIGN.ADD.FORM.SENT_BY.ERROR') }}
          </span>
        </label>

        <label
          v-if="isOnOffType && selectedAction !== 2 && selectedAction !== 3"
        >
          {{ $t('CAMPAIGN.ADD.FORM.SCHEDULED_AT.LABEL') }}
          <woot-date-time-picker
            :value="scheduledAt"
            :confirm-text="$t('CAMPAIGN.ADD.FORM.SCHEDULED_AT.CONFIRM')"
            :placeholder="$t('CAMPAIGN.ADD.FORM.SCHEDULED_AT.PLACEHOLDER')"
            @change="onChange"
          />
        </label>

        <woot-input
          v-if="isOngoingType"
          v-model="endPoint"
          :label="$t('CAMPAIGN.ADD.FORM.END_POINT.LABEL')"
          type="text"
          :class="{ error: $v.endPoint.$error }"
          :error="
            $v.endPoint.$error ? $t('CAMPAIGN.ADD.FORM.END_POINT.ERROR') : ''
          "
          :placeholder="$t('CAMPAIGN.ADD.FORM.END_POINT.PLACEHOLDER')"
          @blur="$v.endPoint.$touch"
        />
        <woot-input
          v-if="isOngoingType"
          v-model="timeOnPage"
          :label="$t('CAMPAIGN.ADD.FORM.TIME_ON_PAGE.LABEL')"
          type="text"
          :class="{ error: $v.timeOnPage.$error }"
          :error="
            $v.timeOnPage.$error
              ? $t('CAMPAIGN.ADD.FORM.TIME_ON_PAGE.ERROR')
              : ''
          "
          :placeholder="$t('CAMPAIGN.ADD.FORM.TIME_ON_PAGE.PLACEHOLDER')"
          @blur="$v.timeOnPage.$touch"
        />
        <label v-if="isOngoingType">
          <input
            v-model="enabled"
            type="checkbox"
            value="enabled"
            name="enabled"
          />
          {{ $t('CAMPAIGN.ADD.FORM.ENABLED') }}
        </label>
        <label v-if="isOngoingType">
          <input
            v-model="triggerOnlyDuringBusinessHours"
            type="checkbox"
            value="triggerOnlyDuringBusinessHours"
            name="triggerOnlyDuringBusinessHours"
          />
          {{ $t('CAMPAIGN.ADD.FORM.TRIGGER_ONLY_BUSINESS_HOURS') }}
        </label>
      </div>

      <div class="modal-footer">
        <woot-button :is-loading="uiFlags.isCreating">
          {{ $t('CAMPAIGN.ADD.CREATE_BUTTON_TEXT') }}
        </woot-button>
        <woot-button variant="clear" @click.prevent="onClose">
          {{ $t('CAMPAIGN.ADD.CANCEL_BUTTON_TEXT') }}
        </woot-button>
      </div>
    </form>
  </div>
</template>

<script>
import { mapGetters } from 'vuex';
import { required, url, minLength } from 'vuelidate/lib/validators';
import alertMixin from 'shared/mixins/alertMixin';
import WootMessageEditor from 'dashboard/components/widgets/WootWriter/Editor';
import campaignMixin from 'shared/mixins/campaignMixin';
import WootDateTimePicker from 'dashboard/components/ui/DateTimePicker.vue';
import {
  CAMPAIGN_MAIL_ACTIONS,
  CAMPAIGN_MAIL_PREFERENCES,
  CAMPAIGN_MAIL_TIME,
} from './constants';

export default {
  components: {
    WootDateTimePicker,
    WootMessageEditor,
  },

  mixins: [alertMixin, campaignMixin],
  data() {
    return {
      title: '',
      subject: '',
      message: '',
      selectedSender: 0,
      selectedInbox: null,
      selectedPreference: null,
      selectedTime: null,
      selectedAction: null,
      selectedMail: null,
      endPoint: '',
      timeOnPage: 10,
      show: true,
      enabled: true,
      triggerOnlyDuringBusinessHours: false,
      scheduledAt: null,
      selectedAudience: [],
      senderList: [],
      presentPreferences: [],
      mailEnabled: false,
      mailAction: CAMPAIGN_MAIL_ACTIONS,
      mailTime: CAMPAIGN_MAIL_TIME,
    };
  },
  validations() {
    const commonValidations = {
      title: {
        required,
      },
      message: {
        required,
      },
      selectedInbox: {
        required,
      },
    };
    if (this.isOngoingType) {
      return {
        ...commonValidations,
        selectedSender: {
          required,
        },
        endPoint: {
          required,
          minLength: minLength(7),
          url,
        },
        timeOnPage: {
          required,
        },
      };
    }
    return {
      ...commonValidations,
      selectedAudience: {
        isEmpty() {
          if (this.mailEnabled) {
            return true;
          }
          return !!this.selectedAudience.length;
        },
      },
      selectedAction: {
        isEmpty() {
          if (this.mailEnabled) {
            return !!this.selectedAction;
          }
          return true;
        },
      },
      selectedMail: {
        isEmpty() {
          if (
            this.mailEnabled &&
            (this.selectedAction === 2 || this.selectedAction === 3)
          ) {
            return !!this.selectedMail;
          }
          return true;
        },
      },
      selectedPreference: {
        isEmpty() {
          if (
            this.mailEnabled &&
            (this.selectedAction === 2 || this.selectedAction === 3)
          ) {
            return !!this.selectedPreference;
          }
          return true;
        },
      },
      selectedTime: {
        isEmpty() {
          if (
            this.mailEnabled &&
            (this.selectedAction === 2 || this.selectedAction === 3)
          ) {
            return !!this.selectedTime;
          }
          return true;
        },
      },
    };
  },
  computed: {
    ...mapGetters({
      uiFlags: 'campaigns/getUIFlags',
      audienceList: 'labels/getLabels',
    }),
    mailCampaigns() {
      return this.$store.getters['campaigns/getMailCampaigns']('one_off');
    },
    mailPreferences() {
      // eslint-disable-next-line vue/no-side-effects-in-computed-properties
      this.presentPreferences = [];
      this.presentReplies.map(item =>
        this.presentPreferences.push(item.custom_attributes.preference)
      );
      return CAMPAIGN_MAIL_PREFERENCES;
    },
    presentReplies() {
      return this.$store.getters['campaigns/getMailReplies']('one_off').filter(
        record =>
          record.custom_attributes.selected_mail === this.selectedMail &&
          record.custom_attributes.action === this.selectedAction
      );
    },

    inboxes() {
      if (this.isOngoingType) {
        return this.$store.getters['inboxes/getWebsiteInboxes'];
      }
      return this.$store.getters['inboxes/getOneOffInboxes'];
    },
    sendersAndBotList() {
      return [
        {
          id: 0,
          name: 'Bot',
        },
        ...this.senderList,
      ];
    },
  },
  methods: {
    onClose() {
      this.$emit('on-close');
    },
    onChange(value) {
      this.scheduledAt = value;
    },
    actionChange() {
      // eslint-disable-next-line no-multi-assign
      this.selectedPreference = this.selectedTime = null;
    },
    async onChangeInbox() {
      try {
        if (
          this.$store.getters['inboxes/checkMailInbox'].filter(
            item => item.id === this.selectedInbox
          ).length > 0
        ) {
          this.mailEnabled = true;
        } else {
          this.mailEnabled = false;
        }
        const response = await this.$store.dispatch('inboxMembers/get', {
          inboxId: this.selectedInbox,
        });
        const {
          data: { payload: inboxMembers },
        } = response;
        this.senderList = inboxMembers;
      } catch (error) {
        const errorMessage =
          error?.response?.message || this.$t('CAMPAIGN.ADD.API.ERROR_MESSAGE');
        this.showAlert(errorMessage);
      }
    },
    getCampaignDetails() {
      let campaignDetails = null;
      if (this.isOngoingType) {
        campaignDetails = {
          title: this.title,
          message: this.message,
          inbox_id: this.selectedInbox,
          sender_id: this.selectedSender || null,
          enabled: this.enabled,
          trigger_only_during_business_hours:
            // eslint-disable-next-line prettier/prettier
            this.triggerOnlyDuringBusinessHours,
          trigger_rules: {
            url: this.endPoint,
            time_on_page: this.timeOnPage,
          },
        };
      } else {
        const audience = this.selectedAudience.map(item => {
          return {
            id: item.id,
            type: 'Label',
          };
        });
        campaignDetails = {
          title: this.title,
          message: this.message,
          inbox_id: this.selectedInbox,
          scheduled_at: this.scheduledAt,
          custom_attributes: {
            mail_subject: this.subject,
            action: this.selectedAction,
            selected_mail: this.selectedMail,
            preference: this.selectedPreference,
            selected_time: this.selectedTime,
          },
          audience,
        };
      }
      return campaignDetails;
    },
    async addCampaign() {
      this.$v.$touch();
      if (this.$v.$invalid) {
        return;
      }
      try {
        const campaignDetails = this.getCampaignDetails();
        await this.$store.dispatch('campaigns/create', campaignDetails);
        this.showAlert(this.$t('CAMPAIGN.ADD.API.SUCCESS_MESSAGE'));
        this.onClose();
      } catch (error) {
        const errorMessage =
          error?.response?.message || this.$t('CAMPAIGN.ADD.API.ERROR_MESSAGE');
        this.showAlert(errorMessage);
      }
    },
  },
};
</script>
<style lang="scss" scoped>
::v-deep .ProseMirror-woot-style {
  height: 8rem;
}
</style>
