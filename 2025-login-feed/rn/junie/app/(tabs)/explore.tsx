// Disabled Explore tab route
import React from 'react';

export const options = {
  href: null as const,
};

export default function DisabledExplore() {
  // Render nothing to avoid contributing views under Fabric
  return null;
}
