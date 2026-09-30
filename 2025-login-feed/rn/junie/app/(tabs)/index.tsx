import React from 'react';

// Disable this route from tabs and linking
export const options = {
  href: null as const,
};

export default function DisabledTabsIndex() {
  // Render nothing to avoid any mount/unmount churn.
  return null;
}
