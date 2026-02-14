import { NavLink } from "react-router";
import { useTranslation } from "react-i18next";
import ISuiteCodeXLogo from "#/assets/branding/isuite-codex-logo.svg?react";
import { I18nKey } from "#/i18n/declaration";
import { StyledTooltip } from "#/components/shared/buttons/styled-tooltip";

export function ISuiteCodeXLogoButton() {
  const { t } = useTranslation();

  const tooltipText = t(I18nKey.BRANDING$ISUITE);
  const ariaLabel = t(I18nKey.BRANDING$ISUITE_LOGO);

  return (
    <StyledTooltip content={tooltipText}>
      <NavLink to="/" aria-label={ariaLabel}>
        <ISuiteCodeXLogo width={46} height={30} />
      </NavLink>
    </StyledTooltip>
  );
}
